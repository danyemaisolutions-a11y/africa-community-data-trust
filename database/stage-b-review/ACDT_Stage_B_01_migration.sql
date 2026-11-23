-- ACDT M6.2 Stage B / Revision 1 / REVIEW BEFORE EXECUTION
-- Supabase PostgreSQL 17. Adds objects; preserves the six existing tables/rows.
-- Execute once as postgres. No automatic appointment of an administrator.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='60s';
DO $preflight$
BEGIN
 IF current_user <> 'postgres' THEN RAISE EXCEPTION 'Run as postgres'; END IF;
 IF to_regclass('public.organizations') IS NULL OR to_regclass('public.governance_audit_logs') IS NULL OR to_regprocedure('auth.uid()') IS NULL THEN RAISE EXCEPTION 'Required Stage A schema missing'; END IF;
 IF to_regclass('public.user_profiles') IS NOT NULL OR to_regclass('public.org_memberships') IS NOT NULL OR to_regclass('public.membership_roles') IS NOT NULL OR to_regclass('public.platform_roles') IS NOT NULL OR EXISTS(SELECT 1 FROM pg_namespace WHERE nspname='acdt_security') THEN RAISE EXCEPTION 'Stage B objects already exist: stop and inspect, do not overwrite'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='public.governance_audit_logs'::regclass AND tgname='governance_audit_logs_no_truncate' AND tgenabled='O' AND NOT tgisinternal) THEN RAISE EXCEPTION 'Commit Stage A first'; END IF;
 IF has_table_privilege('authenticated','public.participants','SELECT') OR has_table_privilege('anon','public.participants','SELECT') OR has_table_privilege('authenticated','public.governance_audit_logs','TRUNCATE') THEN RAISE EXCEPTION 'Stage A privilege checks failed'; END IF;
END $preflight$;

CREATE SCHEMA acdt_security AUTHORIZATION postgres;
REVOKE ALL ON SCHEMA acdt_security FROM PUBLIC,anon,authenticated,service_role;
CREATE TABLE acdt_security.workflow_gate(id integer PRIMARY KEY CHECK(id=1),version bigint NOT NULL DEFAULT 0);
INSERT INTO acdt_security.workflow_gate VALUES(1,0);
CREATE TABLE public.user_profiles(
 user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE RESTRICT,
 display_name text NOT NULL CHECK(length(trim(display_name)) BETWEEN 1 AND 200),
 is_active boolean NOT NULL DEFAULT true,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE acdt_security.organization_trust(
 organization_id uuid PRIMARY KEY REFERENCES public.organizations(id) ON DELETE RESTRICT,
 verified boolean NOT NULL,
 active boolean NOT NULL,
 reviewed_by uuid NOT NULL REFERENCES public.user_profiles(user_id),
 reason text NOT NULL CHECK(length(trim(reason)) BETWEEN 1 AND 2000),
 reviewed_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE public.org_memberships(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
 user_id uuid NOT NULL REFERENCES public.user_profiles(user_id) ON DELETE RESTRICT,
 status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','active','rejected','suspended')),
 requested_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 reviewed_by uuid REFERENCES public.user_profiles(user_id),
 reviewed_at timestamptz,
 review_reason text,
 UNIQUE(organization_id,user_id),
 CHECK((status='pending' AND reviewed_by IS NULL AND reviewed_at IS NULL AND review_reason IS NULL)
 OR (status<>'pending' AND reviewed_by IS NOT NULL AND reviewed_by<>user_id AND reviewed_at IS NOT NULL AND length(trim(review_reason)) BETWEEN 1 AND 2000))
);
CREATE TABLE public.membership_roles(
 membership_id uuid NOT NULL REFERENCES public.org_memberships(id) ON DELETE RESTRICT,
 role text NOT NULL CHECK(role IN ('org_admin','researcher','governance_reviewer')),
 assigned_by uuid NOT NULL REFERENCES public.user_profiles(user_id),
 assigned_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 PRIMARY KEY(membership_id,role)
);
CREATE TABLE public.platform_roles(
 user_id uuid NOT NULL REFERENCES public.user_profiles(user_id),
 role text NOT NULL CHECK(role='platform_governor'),
 assigned_by uuid NOT NULL REFERENCES public.user_profiles(user_id),
 assigned_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 PRIMARY KEY(user_id,role)
);
CREATE INDEX org_memberships_user_status_idx ON public.org_memberships(user_id,status);
CREATE INDEX org_memberships_org_status_idx ON public.org_memberships(organization_id,status);

-- These invoker helpers are private. Only the public, validated definer RPCs call them.
CREATE FUNCTION acdt_security.audit(p_actor uuid,p_action text,p_target uuid,p_detail jsonb) RETURNS void
LANGUAGE sql SET search_path='' AS $f$
 INSERT INTO public.governance_audit_logs(actor_id,action_type,purpose_hash,records_impacted,metadata)
 VALUES(p_actor::text,p_action,
 encode(sha256(convert_to(jsonb_build_object('action',p_action,'target',p_target,'detail',p_detail)::text,'UTF8')),'hex'),
 1,jsonb_build_object('stage','M6.2-B','target_id',p_target,'detail',p_detail));
$f$;
CREATE FUNCTION acdt_security.enter_workflow(p_profile_required boolean DEFAULT true) RETURNS uuid
LANGUAGE plpgsql SET search_path='' AS $f$
DECLARE u uuid:=auth.uid(); BEGIN
 IF current_setting('transaction_isolation')<>'read committed' THEN RAISE EXCEPTION 'READ COMMITTED required' USING ERRCODE='22023'; END IF;
 IF u IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 UPDATE acdt_security.workflow_gate SET version=version+1 WHERE id=1;
 IF p_profile_required AND NOT EXISTS(SELECT 1 FROM public.user_profiles WHERE user_id=u AND is_active) THEN RAISE EXCEPTION 'Active profile required' USING ERRCODE='42501'; END IF;
 RETURN u;
END $f$;
CREATE FUNCTION acdt_security.deny_if(p_condition boolean) RETURNS void
LANGUAGE plpgsql SET search_path='' AS $f$
BEGIN IF p_condition IS DISTINCT FROM false THEN RAISE EXCEPTION 'Action not permitted or invalid input' USING ERRCODE='42501'; END IF; END $f$;
CREATE FUNCTION acdt_security.governor(p_user uuid) RETURNS boolean
LANGUAGE sql STABLE SET search_path='' AS $f$
 SELECT EXISTS(SELECT 1 FROM public.platform_roles r JOIN public.user_profiles p ON p.user_id=r.user_id WHERE r.user_id=p_user AND r.role='platform_governor' AND p.is_active)
$f$;
CREATE FUNCTION acdt_security.trusted_org(p_org uuid) RETURNS boolean
LANGUAGE sql STABLE SET search_path='' AS $f$
 SELECT EXISTS(SELECT 1 FROM acdt_security.organization_trust WHERE organization_id=p_org AND verified AND active)
$f$;
CREATE FUNCTION acdt_security.org_admin(p_user uuid,p_org uuid) RETURNS boolean
LANGUAGE sql STABLE SET search_path='' AS $f$
 SELECT acdt_security.trusted_org(p_org) AND EXISTS(
 SELECT 1 FROM public.org_memberships m JOIN public.membership_roles r ON r.membership_id=m.id
 JOIN public.user_profiles p ON p.user_id=m.user_id
 WHERE m.user_id=p_user AND m.organization_id=p_org AND m.status='active' AND r.role='org_admin' AND p.is_active)
$f$;

CREATE FUNCTION public.acdt_register_profile(p_display_name text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE u uuid:=acdt_security.enter_workflow(false); BEGIN
 PERFORM acdt_security.deny_if(p_display_name IS NULL OR length(trim(p_display_name)) NOT BETWEEN 1 AND 200);
 INSERT INTO public.user_profiles(user_id,display_name) VALUES(u,trim(p_display_name));
 PERFORM acdt_security.audit(u,'profile.registered',u,'{}'::jsonb);
 RETURN jsonb_build_object('user_id',u);
END $f$;

CREATE FUNCTION public.acdt_set_org_trust(p_organization uuid,p_verified boolean,p_active boolean,p_reason text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE u uuid:=acdt_security.enter_workflow(); BEGIN
 PERFORM acdt_security.deny_if(NOT acdt_security.governor(u) OR p_verified IS NULL OR p_active IS NULL OR p_reason IS NULL OR length(trim(p_reason)) NOT BETWEEN 1 AND 2000);
 INSERT INTO acdt_security.organization_trust(organization_id,verified,active,reviewed_by,reason)
 VALUES(p_organization,p_verified,p_active,u,trim(p_reason))
 ON CONFLICT(organization_id) DO UPDATE SET verified=EXCLUDED.verified,active=EXCLUDED.active,reviewed_by=u,reason=EXCLUDED.reason,reviewed_at=clock_timestamp();
 PERFORM acdt_security.audit(u,'organization.trust_changed',p_organization,jsonb_build_object('verified',p_verified,'active',p_active,'reason',trim(p_reason)));
 RETURN jsonb_build_object('ok',true);
END $f$;

CREATE FUNCTION public.acdt_request_membership(p_organization uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE u uuid:=acdt_security.enter_workflow(); m public.org_memberships%ROWTYPE; BEGIN
 PERFORM acdt_security.deny_if(NOT acdt_security.trusted_org(p_organization));
 SELECT * INTO m FROM public.org_memberships WHERE organization_id=p_organization AND user_id=u;
 IF m.id IS NULL THEN
 INSERT INTO public.org_memberships(organization_id,user_id) VALUES(p_organization,u) RETURNING * INTO m;
 ELSE
 -- Suspension cannot be bypassed by reapplying. Rejected applicants may reapply.
 PERFORM acdt_security.deny_if(m.status<>'rejected');
 UPDATE public.org_memberships SET status='pending',requested_at=clock_timestamp(),reviewed_by=NULL,reviewed_at=NULL,review_reason=NULL WHERE id=m.id RETURNING * INTO m;
 END IF;
 PERFORM acdt_security.audit(u,'membership.requested',m.id,jsonb_build_object('organization_id',p_organization));
 RETURN jsonb_build_object('membership_id',m.id,'status',m.status);
END $f$;

CREATE FUNCTION public.acdt_review_membership(p_membership uuid,p_status text,p_reason text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE u uuid:=acdt_security.enter_workflow(); m public.org_memberships%ROWTYPE; BEGIN
 SELECT * INTO m FROM public.org_memberships WHERE id=p_membership;
 PERFORM acdt_security.deny_if(m.id IS NULL OR m.user_id=u OR NOT acdt_security.trusted_org(m.organization_id)
 OR NOT (acdt_security.governor(u) OR acdt_security.org_admin(u,m.organization_id))
 OR p_reason IS NULL OR length(trim(p_reason)) NOT BETWEEN 1 AND 2000
 OR NOT EXISTS(SELECT 1 FROM public.user_profiles WHERE user_id=m.user_id AND is_active));
 PERFORM acdt_security.deny_if(NOT ((m.status='pending' AND p_status IN ('active','rejected')) OR (m.status='active' AND p_status='suspended') OR (m.status='suspended' AND p_status='active')));
 UPDATE public.org_memberships SET status=p_status,reviewed_by=u,reviewed_at=clock_timestamp(),review_reason=trim(p_reason) WHERE id=m.id;
 IF p_status='suspended' THEN DELETE FROM public.membership_roles WHERE membership_id=m.id; END IF;
 PERFORM acdt_security.audit(u,'membership.'||p_status,m.id,jsonb_build_object('organization_id',m.organization_id,'previous_status',m.status,'reason',trim(p_reason),'roles_removed',p_status='suspended'));
 RETURN jsonb_build_object('membership_id',m.id,'status',p_status);
END $f$;

CREATE FUNCTION public.acdt_assign_org_role(p_membership uuid,p_role text,p_enabled boolean) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE u uuid:=acdt_security.enter_workflow(); m public.org_memberships%ROWTYPE; BEGIN
 SELECT * INTO m FROM public.org_memberships WHERE id=p_membership;
 PERFORM acdt_security.deny_if(m.id IS NULL OR m.user_id=u OR p_enabled IS NULL OR p_role NOT IN ('org_admin','researcher','governance_reviewer'));
 -- Org admins can appoint researchers only. Governance appoints admins/reviewers.
 PERFORM acdt_security.deny_if(NOT (acdt_security.governor(u) OR (p_role='researcher' AND acdt_security.org_admin(u,m.organization_id))));
 IF p_enabled THEN
 PERFORM acdt_security.deny_if(m.status<>'active' OR NOT acdt_security.trusted_org(m.organization_id) OR NOT EXISTS(SELECT 1 FROM public.user_profiles WHERE user_id=m.user_id AND is_active));
 INSERT INTO public.membership_roles(membership_id,role,assigned_by) VALUES(m.id,p_role,u) ON CONFLICT DO NOTHING;
 ELSE DELETE FROM public.membership_roles WHERE membership_id=m.id AND role=p_role;
 END IF;
 PERFORM acdt_security.audit(u,'organization.role_changed',m.id,jsonb_build_object('role',p_role,'enabled',p_enabled));
 RETURN jsonb_build_object('ok',true);
END $f$;

CREATE FUNCTION public.acdt_assign_platform_role(p_user uuid,p_role text,p_enabled boolean) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE u uuid:=acdt_security.enter_workflow(); BEGIN
 PERFORM acdt_security.deny_if(NOT acdt_security.governor(u) OR p_user=u OR p_role IS DISTINCT FROM 'platform_governor' OR p_enabled IS NULL);
 IF p_enabled THEN
 PERFORM acdt_security.deny_if(NOT EXISTS(SELECT 1 FROM public.user_profiles WHERE user_id=p_user AND is_active));
 INSERT INTO public.platform_roles(user_id,role,assigned_by) VALUES(p_user,p_role,u) ON CONFLICT DO NOTHING;
 ELSE DELETE FROM public.platform_roles WHERE user_id=p_user AND role=p_role;
 END IF;
 PERFORM acdt_security.audit(u,'platform.role_changed',p_user,jsonb_build_object('role',p_role,'enabled',p_enabled));
 RETURN jsonb_build_object('ok',true);
END $f$;

CREATE FUNCTION public.acdt_my_identity() RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE u uuid:=auth.uid(); result jsonb; BEGIN
 IF u IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 SELECT jsonb_build_object('user_id',p.user_id,'display_name',p.display_name,'is_active',p.is_active,
 'memberships',coalesce((SELECT jsonb_agg(jsonb_build_object('membership_id',m.id,'organization_id',m.organization_id,'status',m.status,
 'organization_trusted',acdt_security.trusted_org(m.organization_id),
 'roles',coalesce((SELECT jsonb_agg(r.role ORDER BY r.role) FROM public.membership_roles r WHERE r.membership_id=m.id),'[]'::jsonb)) ORDER BY m.requested_at,m.id)
 FROM public.org_memberships m WHERE m.user_id=u),'[]'::jsonb),
 'platform_governor',acdt_security.governor(u)) INTO result FROM public.user_profiles p WHERE p.user_id=u;
 RETURN coalesce(result,jsonb_build_object('user_id',u,'profile_registered',false));
END $f$;

-- Bootstrap is an explicit, privileged operation; never a public RPC.
-- SECURITY INVOKER plus role check; no ordinary client can call it.
CREATE FUNCTION acdt_security.bootstrap_first_governor(p_user uuid,p_display_name text,p_reason text) RETURNS jsonb
LANGUAGE plpgsql SET search_path='' AS $f$
BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'Database administrator required' USING ERRCODE='42501'; END IF;
 IF current_setting('transaction_isolation')<>'read committed' THEN RAISE EXCEPTION 'READ COMMITTED required' USING ERRCODE='22023'; END IF;
 UPDATE acdt_security.workflow_gate SET version=version+1 WHERE id=1;
 PERFORM acdt_security.deny_if(EXISTS(SELECT 1 FROM public.platform_roles) OR p_reason IS NULL OR length(trim(p_reason)) NOT BETWEEN 1 AND 2000 OR p_display_name IS NULL OR length(trim(p_display_name)) NOT BETWEEN 1 AND 200 OR NOT EXISTS(SELECT 1 FROM auth.users WHERE id=p_user));
 PERFORM acdt_security.deny_if(NOT EXISTS(SELECT 1 FROM auth.users WHERE id=p_user));
 INSERT INTO public.user_profiles(user_id,display_name) VALUES(p_user,trim(p_display_name)) ON CONFLICT(user_id) DO NOTHING;
 PERFORM acdt_security.deny_if(NOT EXISTS(SELECT 1 FROM public.user_profiles WHERE user_id=p_user AND is_active));
 INSERT INTO public.platform_roles(user_id,role,assigned_by) VALUES(p_user,'platform_governor',p_user);
 PERFORM acdt_security.audit(p_user,'platform.initial_governor',p_user,jsonb_build_object('database_actor',current_user,'reason',trim(p_reason),'bootstrap',true));
 RETURN jsonb_build_object('governor_user_id',p_user,'appointed',true);
END $f$;

-- Harden every new table; trusted postgres-owned functions deliberately use owner RLS bypass.
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.org_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.membership_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE acdt_security.organization_trust ENABLE ROW LEVEL SECURITY;
ALTER TABLE acdt_security.workflow_gate ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.user_profiles,public.org_memberships,public.membership_roles,public.platform_roles FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON ALL TABLES IN SCHEMA acdt_security FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA acdt_security FROM PUBLIC,anon,authenticated,service_role;

-- Explicitly revoke PUBLIC AND Supabase's named-role defaults for each new public RPC.
DO $permissions$
DECLARE f regprocedure; BEGIN
 FOR f IN SELECT p.oid::regprocedure FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
 WHERE n.nspname='public' AND p.proname IN ('acdt_register_profile','acdt_set_org_trust','acdt_request_membership','acdt_review_membership','acdt_assign_org_role','acdt_assign_platform_role','acdt_my_identity')
 LOOP
 EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon, authenticated, service_role',f);
 EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated',f);
 END LOOP;
END $permissions$;
COMMIT;
