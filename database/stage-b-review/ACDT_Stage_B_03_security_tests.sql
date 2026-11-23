-- Stage B SQL security tests. DISPOSABLE DATABASE ONLY.
-- Apply Stage A + Stage B first; run BEFORE real bootstrap (tests roll back).
-- No pgTAP required. Synthetic auth fixtures assume no custom auth.users triggers.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='60s';
SELECT set_config('acdt_b_test.count','0',true);
CREATE FUNCTION pg_temp.check_true(b boolean,label text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
 IF b IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %',label; END IF;
 PERFORM set_config('acdt_b_test.count',(current_setting('acdt_b_test.count')::integer+1)::text,true);
END $f$;
CREATE FUNCTION pg_temp.call_as(u uuid,q text) RETURNS jsonb LANGUAGE plpgsql SECURITY INVOKER AS $f$
DECLARE result jsonb; old_sub text:=current_setting('request.jwt.claim.sub',true); old_claims text:=current_setting('request.jwt.claims',true);
BEGIN
 PERFORM set_config('request.jwt.claim.sub',coalesce(u::text,''),true);
 PERFORM set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);
 EXECUTE 'SET LOCAL ROLE authenticated';
 EXECUTE q INTO result;
 EXECUTE 'RESET ROLE';
 PERFORM set_config('request.jwt.claim.sub',coalesce(old_sub,''),true);
 PERFORM set_config('request.jwt.claims',coalesce(old_claims,''),true);
 RETURN result;
EXCEPTION WHEN OTHERS THEN
 EXECUTE 'RESET ROLE';
 RAISE;
END $f$;
CREATE FUNCTION pg_temp.expect_denied(u uuid,q text,label text) RETURNS void LANGUAGE plpgsql AS $f$
DECLARE rejected boolean:=false;
BEGIN
 BEGIN PERFORM pg_temp.call_as(u,q); EXCEPTION WHEN insufficient_privilege THEN rejected:=true; END;
 PERFORM pg_temp.check_true(rejected,label);
END $f$;
DO $tests$
DECLARE
 g uuid:=gen_random_uuid(); a uuid:=gen_random_uuid(); b uuid:=gen_random_uuid(); member_user uuid:=gen_random_uuid();
 org_a uuid:=gen_random_uuid(); org_b uuid:=gen_random_uuid();
 ma uuid; mb uuid; mm uuid; r jsonb; f record; rejected boolean:=false; before_count bigint;
BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'Run tests as postgres'; END IF;
 IF EXISTS(SELECT 1 FROM public.platform_roles) THEN RAISE EXCEPTION 'Run in a disposable copy BEFORE real bootstrap'; END IF;
 INSERT INTO auth.users(id,email,aud,role) VALUES
 (g,g::text||'@acdt-test.invalid','authenticated','authenticated'),
 (a,a::text||'@acdt-test.invalid','authenticated','authenticated'),
 (b,b::text||'@acdt-test.invalid','authenticated','authenticated'),
 (member_user,member_user::text||'@acdt-test.invalid','authenticated','authenticated');
 INSERT INTO public.organizations(id,name,slug) VALUES(org_a,'Synthetic A',org_a::text),(org_b,'Synthetic B',org_b::text);
 r:=acdt_security.bootstrap_first_governor(g,'Synthetic governor','TEST ONLY');
 PERFORM pg_temp.check_true((r->>'appointed')::boolean,'explicit bootstrap succeeds');
 BEGIN
 PERFORM acdt_security.bootstrap_first_governor(a,'Second','TEST ONLY');
 EXCEPTION WHEN insufficient_privilege THEN rejected:=true; END;
 PERFORM pg_temp.check_true(rejected,'bootstrap cannot be repeated');
 r:=pg_temp.call_as(a,$q$SELECT public.acdt_register_profile('Synthetic admin A')$q$);
 PERFORM pg_temp.check_true((r->>'user_id')::uuid=a,'profile uses caller identity');
 PERFORM pg_temp.call_as(b,$q$SELECT public.acdt_register_profile('Synthetic admin B')$q$);
 PERFORM pg_temp.call_as(member_user,$q$SELECT public.acdt_register_profile('Synthetic member')$q$);
 PERFORM pg_temp.expect_denied(NULL,$q$SELECT public.acdt_register_profile('No identity')$q$,'missing identity rejected');
 FOR f IN SELECT p.oid,n.nspname,p.proname,p.prosecdef,p.proconfig FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.proname IN ('acdt_register_profile','acdt_set_org_trust','acdt_request_membership','acdt_review_membership','acdt_assign_org_role','acdt_assign_platform_role','acdt_my_identity') LOOP
 PERFORM pg_temp.check_true(NOT has_function_privilege('anon',f.oid,'EXECUTE'),'anonymous RPC execute denied: '||f.proname);
 PERFORM pg_temp.check_true(has_function_privilege('authenticated',f.oid,'EXECUTE'),'authenticated RPC executable: '||f.proname);
 PERFORM pg_temp.check_true(NOT has_function_privilege('service_role',f.oid,'EXECUTE'),'service-role RPC execute denied: '||f.proname);
 PERFORM pg_temp.check_true(f.prosecdef AND f.proconfig @> ARRAY['search_path=""'],'definer search_path pinned: '||f.proname);
 END LOOP;
 PERFORM pg_temp.expect_denied(a,'SELECT public.acdt_request_membership('||quote_literal(org_a)||')','unverified organisation membership rejected');
 PERFORM pg_temp.expect_denied(a,format('SELECT public.acdt_set_org_trust(%L,true,true,%L)',org_a,'forged'),'ordinary user cannot verify organization');
 PERFORM pg_temp.call_as(g,format('SELECT public.acdt_set_org_trust(%L,true,true,%L)',org_a,'TEST ONLY'));
 PERFORM pg_temp.call_as(g,format('SELECT public.acdt_set_org_trust(%L,true,true,%L)',org_b,'TEST ONLY'));
 r:=pg_temp.call_as(a,format('SELECT public.acdt_request_membership(%L)',org_a)); ma:=(r->>'membership_id')::uuid;
 r:=pg_temp.call_as(b,format('SELECT public.acdt_request_membership(%L)',org_b)); mb:=(r->>'membership_id')::uuid;
 r:=pg_temp.call_as(member_user,format('SELECT public.acdt_request_membership(%L)',org_a)); mm:=(r->>'membership_id')::uuid;
 PERFORM pg_temp.expect_denied(a,format('SELECT public.acdt_review_membership(%L,%L,%L)',ma,'active','self'),'self membership approval rejected');
 PERFORM pg_temp.call_as(g,format('SELECT public.acdt_review_membership(%L,%L,%L)',ma,'active','TEST ONLY'));
 PERFORM pg_temp.call_as(g,format('SELECT public.acdt_review_membership(%L,%L,%L)',mb,'active','TEST ONLY'));
 PERFORM pg_temp.call_as(g,format('SELECT public.acdt_assign_org_role(%L,%L,true)',ma,'org_admin'));
 PERFORM pg_temp.call_as(g,format('SELECT public.acdt_assign_org_role(%L,%L,true)',mb,'org_admin'));
 PERFORM pg_temp.expect_denied(b,format('SELECT public.acdt_review_membership(%L,%L,%L)',mm,'active','cross-tenant'),'other organization admin cannot approve');
 PERFORM pg_temp.call_as(a,format('SELECT public.acdt_review_membership(%L,%L,%L)',mm,'active','TEST ONLY'));
 PERFORM pg_temp.check_true((SELECT status='active' FROM public.org_memberships WHERE id=mm),'same-org administrator can approve');
 PERFORM pg_temp.call_as(a,format('SELECT public.acdt_assign_org_role(%L,%L,true)',mm,'researcher'));
 PERFORM pg_temp.check_true(EXISTS(SELECT 1 FROM public.membership_roles WHERE membership_id=mm AND role='researcher'),'admin can appoint researcher');
 PERFORM pg_temp.expect_denied(a,format('SELECT public.acdt_assign_org_role(%L,%L,true)',mm,'governance_reviewer'),'admin cannot manufacture governance reviewer');
 PERFORM pg_temp.expect_denied(a,format('SELECT public.acdt_assign_org_role(%L,%L,true)',mm,'org_admin'),'admin cannot appoint another admin');
 PERFORM pg_temp.expect_denied(a,format('SELECT public.acdt_assign_org_role(%L,%L,true)',ma,'researcher'),'self role change rejected');
 PERFORM pg_temp.expect_denied(member_user,format('SELECT public.acdt_assign_platform_role(%L,%L,true)',member_user,'platform_governor'),'self platform promotion rejected');
 PERFORM pg_temp.expect_denied(member_user,'SELECT to_jsonb(p) FROM public.user_profiles p LIMIT 1','direct profile table read denied');
 PERFORM pg_temp.expect_denied(member_user,format('SELECT acdt_security.bootstrap_first_governor(%L,%L,%L)',member_user,'bad','bad'),'client cannot call private bootstrap');
 r:=pg_temp.call_as(member_user,'SELECT public.acdt_my_identity()');
 PERFORM pg_temp.check_true((r->>'user_id')::uuid=member_user AND jsonb_array_length(r->'memberships')=1,'own identity only');
 SELECT count(*) INTO before_count FROM public.governance_audit_logs;
 PERFORM pg_temp.expect_denied(member_user,format('SELECT public.acdt_assign_org_role(%L,%L,true)',mm,'org_admin'),'unauthorised mutation fails');
 PERFORM pg_temp.check_true((SELECT count(*) FROM public.governance_audit_logs)=before_count,'failed mutation leaves no partial audit');
 PERFORM pg_temp.call_as(a,format('SELECT public.acdt_review_membership(%L,%L,%L)',mm,'suspended','TEST ONLY'));
 PERFORM pg_temp.check_true(NOT EXISTS(SELECT 1 FROM public.membership_roles WHERE membership_id=mm),'suspension removes roles');
 PERFORM pg_temp.expect_denied(member_user,format('SELECT public.acdt_request_membership(%L)',org_a),'suspension cannot be bypassed by reapplying');
 PERFORM pg_temp.call_as(a,format('SELECT public.acdt_review_membership(%L,%L,%L)',mm,'active','TEST ONLY'));
 PERFORM pg_temp.check_true(NOT EXISTS(SELECT 1 FROM public.membership_roles WHERE membership_id=mm),'reactivation does not resurrect roles');
 PERFORM pg_temp.call_as(g,format('SELECT public.acdt_set_org_trust(%L,true,false,%L)',org_a,'TEST ONLY'));
 PERFORM pg_temp.expect_denied(a,format('SELECT public.acdt_assign_org_role(%L,%L,true)',mm,'researcher'),'inactive organisation disables admin authority');
 PERFORM pg_temp.check_true(EXISTS(SELECT 1 FROM public.governance_audit_logs WHERE actor_id=g::text AND action_type='platform.initial_governor'),'bootstrap recorded with authenticated-user UUID');
END $tests$;
SELECT 'PASS: sequential checks completed; synthetic data will be rolled back' AS result,
 current_setting('acdt_b_test.count')::integer AS assertions_passed;
ROLLBACK;
