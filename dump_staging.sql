

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "backup_data";


ALTER SCHEMA "backup_data" OWNER TO "postgres";


CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."backup_project_list_changes"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO backup_data.project_list_backup (
    id,
    project_name,
    project_info,
    shortcode_link,
    project_sequence_number,
    created_by,
    created_at,
    updated_by,
    updated_at,
    backup_created_at
  )
  VALUES (
    NEW.id,
    NEW.project_name,
    NEW.project_info,
    NEW.shortcode_link,
    NEW.project_sequence_number,
    NEW.created_by,
    NEW.created_at,
    NEW.updated_by,
    NEW.updated_at,
    NOW()
  );
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."backup_project_list_changes"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."enforce_lowercase_fields"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN
  NEW.email = LOWER(NEW.email);
  NEW.display_id = LOWER(NEW.display_id);
  NEW.website = LOWER(NEW.website);
  NEW.username = lower(NEW.username);
  NEW.full_name = lower(NEW.full_name);
  RETURN NEW;
END;$$;


ALTER FUNCTION "public"."enforce_lowercase_fields"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url, email, has_set_password)
  VALUES (
    NEW.id, 
    NEW.raw_user_meta_data->>'full_name', 
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.email,
    false -- Set has_set_password to false initially
  );
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_project_owner"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Ensure the user has permission to insert into project_permissions
  INSERT INTO public.project_permissions (project_id, user_id, role)
  VALUES (NEW.id, auth.uid(), 'owner')
  ON CONFLICT DO NOTHING; -- Avoid duplicate entries

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_project_owner"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "backup_data"."project_list_backup" (
    "id" "uuid" NOT NULL,
    "project_name" "text" NOT NULL,
    "project_info" "text",
    "shortcode_link" "text",
    "project_sequence_number" integer,
    "created_by" "uuid",
    "created_at" timestamp with time zone NOT NULL,
    "updated_by" "uuid",
    "updated_at" timestamp with time zone,
    "backup_created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "backup_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "backup_data"."project_list_backup" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."blocked_users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "blocker_id" "uuid" NOT NULL,
    "blocked_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."blocked_users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."connections" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user1_id" "uuid" NOT NULL,
    "user2_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_blocked" boolean DEFAULT false
);


ALTER TABLE "public"."connections" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "updated_at" timestamp with time zone,
    "username" "text",
    "full_name" "text",
    "avatar_url" "text",
    "website" "text",
    "display_id" "text",
    "email" "text",
    "has_set_password" boolean DEFAULT false,
    CONSTRAINT "username_length" CHECK (("char_length"("username") >= 3))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."community" WITH ("security_invoker"='true') AS
 SELECT "p"."id" AS "user_id",
    "p"."email",
    "p"."display_id",
    "p"."full_name",
    "p"."avatar_url",
    "p"."website",
    "p"."updated_at",
        CASE
            WHEN ("c"."id" IS NOT NULL) THEN true
            ELSE false
        END AS "is_connected",
        CASE
            WHEN ("bu"."blocker_id" IS NOT NULL) THEN true
            ELSE false
        END AS "is_blocked",
        CASE
            WHEN ("bu2"."blocked_id" IS NOT NULL) THEN true
            ELSE false
        END AS "is_blocked_by"
   FROM ((("public"."profiles" "p"
     LEFT JOIN "public"."connections" "c" ON (((("c"."user1_id" = "auth"."uid"()) AND ("c"."user2_id" = "p"."id")) OR (("c"."user2_id" = "auth"."uid"()) AND ("c"."user1_id" = "p"."id")))))
     LEFT JOIN "public"."blocked_users" "bu" ON ((("bu"."blocker_id" = "auth"."uid"()) AND ("bu"."blocked_id" = "p"."id"))))
     LEFT JOIN "public"."blocked_users" "bu2" ON ((("bu2"."blocker_id" = "p"."id") AND ("bu2"."blocked_id" = "auth"."uid"()))));


ALTER TABLE "public"."community" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."connection_profiles" AS
 SELECT "c"."id" AS "connection_id",
    "c"."created_at",
        CASE
            WHEN ("c"."user1_id" = "auth"."uid"()) THEN "c"."user1_id"
            ELSE "c"."user2_id"
        END AS "user_id",
        CASE
            WHEN ("c"."user1_id" = "auth"."uid"()) THEN "p1"."email"
            ELSE "p2"."email"
        END AS "user_email",
        CASE
            WHEN ("c"."user1_id" = "auth"."uid"()) THEN "p1"."display_id"
            ELSE "p2"."display_id"
        END AS "user_display_id",
        CASE
            WHEN ("c"."user1_id" = "auth"."uid"()) THEN "p1"."full_name"
            ELSE "p2"."full_name"
        END AS "user_full_name",
        CASE
            WHEN ("c"."user1_id" = "auth"."uid"()) THEN "p1"."website"
            ELSE "p2"."website"
        END AS "user_website",
        CASE
            WHEN ("c"."user1_id" = "auth"."uid"()) THEN "c"."user2_id"
            ELSE "c"."user1_id"
        END AS "other_user_id",
        CASE
            WHEN ("c"."user1_id" = "auth"."uid"()) THEN "p2"."email"
            ELSE "p1"."email"
        END AS "other_user_email",
        CASE
            WHEN ("c"."user1_id" = "auth"."uid"()) THEN "p2"."display_id"
            ELSE "p1"."display_id"
        END AS "other_user_display_id",
        CASE
            WHEN ("c"."user1_id" = "auth"."uid"()) THEN "p2"."full_name"
            ELSE "p1"."full_name"
        END AS "other_user_full_name",
        CASE
            WHEN ("c"."user1_id" = "auth"."uid"()) THEN "p2"."website"
            ELSE "p1"."website"
        END AS "other_user_website",
    "c"."is_blocked"
   FROM (("public"."connections" "c"
     JOIN "public"."profiles" "p1" ON (("c"."user1_id" = "p1"."id")))
     JOIN "public"."profiles" "p2" ON (("c"."user2_id" = "p2"."id")));


ALTER TABLE "public"."connection_profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."invitations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "project_id" "uuid" NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "recipient_email" "text" NOT NULL,
    "role" "text" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."invitations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "connection_id" "uuid" NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "message" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."project_list" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "project_name" "text" NOT NULL,
    "project_info" "text",
    "shortcode_link" "text",
    "project_sequence_number" integer,
    "created_by" "uuid" DEFAULT "auth"."uid"(),
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_by" "uuid" DEFAULT "auth"."uid"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "owner_id" "uuid" DEFAULT "auth"."uid"()
);


ALTER TABLE "public"."project_list" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."project_permissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "project_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "project_permissions_role_check" CHECK (("role" = ANY (ARRAY['owner'::"text", 'admin'::"text", 'editor'::"text", 'viewer'::"text"])))
);


ALTER TABLE "public"."project_permissions" OWNER TO "postgres";


ALTER TABLE ONLY "backup_data"."project_list_backup"
    ADD CONSTRAINT "project_list_backup_pkey" PRIMARY KEY ("backup_id");



ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "connections_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."invitations"
    ADD CONSTRAINT "invitations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_display_id_key" UNIQUE ("display_id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."project_list"
    ADD CONSTRAINT "project_list_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."project_permissions"
    ADD CONSTRAINT "project_permissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "unique_blocking" UNIQUE ("blocker_id", "blocked_id");



CREATE INDEX "idx_blocked_id" ON "public"."blocked_users" USING "btree" ("blocked_id");



CREATE INDEX "idx_blocker_id" ON "public"."blocked_users" USING "btree" ("blocker_id");



CREATE INDEX "idx_profiles_display_id" ON "public"."profiles" USING "btree" ("lower"("display_id"));



CREATE INDEX "idx_profiles_email" ON "public"."profiles" USING "btree" ("lower"("email"));



CREATE INDEX "idx_profiles_website" ON "public"."profiles" USING "btree" ("lower"("website"));



CREATE UNIQUE INDEX "unique_connection_index" ON "public"."connections" USING "btree" (LEAST("user1_id", "user2_id"), GREATEST("user1_id", "user2_id"));



CREATE OR REPLACE TRIGGER "lowercase_profiles_fields" BEFORE INSERT OR UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_lowercase_fields"();



CREATE OR REPLACE TRIGGER "set_project_owner_trigger" AFTER INSERT ON "public"."project_list" FOR EACH ROW EXECUTE FUNCTION "public"."set_project_owner"();



CREATE OR REPLACE TRIGGER "trigger_backup_project_list" AFTER INSERT OR UPDATE ON "public"."project_list" FOR EACH ROW EXECUTE FUNCTION "public"."backup_project_list_changes"();



CREATE OR REPLACE TRIGGER "update_connections_updated_at" BEFORE UPDATE ON "public"."connections" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_invitations_updated_at" BEFORE UPDATE ON "public"."invitations" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_messages_updated_at" BEFORE UPDATE ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_profiles_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_project_list_updated_at" BEFORE UPDATE ON "public"."project_list" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_project_permissions_updated_at" BEFORE UPDATE ON "public"."project_permissions" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_blocked_id_fkey" FOREIGN KEY ("blocked_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."blocked_users"
    ADD CONSTRAINT "blocked_users_blocker_id_fkey" FOREIGN KEY ("blocker_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "connections_user1_id_fkey" FOREIGN KEY ("user1_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "connections_user2_id_fkey" FOREIGN KEY ("user2_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invitations"
    ADD CONSTRAINT "invitations_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."project_list"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invitations"
    ADD CONSTRAINT "invitations_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_connection_id_fkey" FOREIGN KEY ("connection_id") REFERENCES "public"."connections"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."project_list"
    ADD CONSTRAINT "project_list_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."project_list"
    ADD CONSTRAINT "project_list_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."project_list"
    ADD CONSTRAINT "project_list_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."project_permissions"
    ADD CONSTRAINT "project_permissions_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."project_list"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."project_permissions"
    ADD CONSTRAINT "project_permissions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."project_permissions"
    ADD CONSTRAINT "project_permissions_user_id_profiles_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



CREATE POLICY "Allow auth to insert and validate" ON "backup_data"."project_list_backup" FOR INSERT WITH CHECK (true);



CREATE POLICY "Allow select for all" ON "backup_data"."project_list_backup" FOR SELECT USING (true);



ALTER TABLE "backup_data"."project_list_backup" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Allow all authenticated users to select all profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow owners and admins to create roles" ON "public"."project_permissions" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."project_permissions" "pp"
  WHERE (("pp"."project_id" = "project_permissions"."project_id") AND ("pp"."user_id" = "auth"."uid"()) AND ("pp"."role" = ANY (ARRAY['owner'::"text", 'admin'::"text"]))))));



CREATE POLICY "Allow owners and admins to delete roles" ON "public"."project_permissions" FOR DELETE USING (((EXISTS ( SELECT 1
   FROM "public"."project_permissions" "pp"
  WHERE (("pp"."project_id" = "project_permissions"."project_id") AND ("pp"."user_id" = "auth"."uid"()) AND ("pp"."role" = ANY (ARRAY['owner'::"text", 'admin'::"text"]))))) AND (NOT (("role" = 'owner'::"text") AND (( SELECT "count"(*) AS "count"
   FROM "public"."project_permissions" "project_permissions_1"
  WHERE (("project_permissions_1"."project_id" = "project_permissions_1"."project_id") AND ("project_permissions_1"."role" = 'owner'::"text"))) = 1)))));



CREATE POLICY "Allow owners and admins to update roles" ON "public"."project_permissions" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."project_permissions" "pp"
  WHERE (("pp"."project_id" = "project_permissions"."project_id") AND ("pp"."user_id" = "auth"."uid"()) AND ("pp"."role" = ANY (ARRAY['owner'::"text", 'admin'::"text"]))))));



CREATE POLICY "Allow project creator to add initial permission" ON "public"."project_permissions" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."project_list"
  WHERE (("project_list"."id" = "project_permissions"."project_id") AND ("project_list"."created_by" = "auth"."uid"())))));



CREATE POLICY "Allow project owners and admins to create invitations" ON "public"."invitations" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."project_permissions"
  WHERE (("project_permissions"."project_id" IN ( SELECT "project_list"."id"
           FROM "public"."project_list"
          WHERE ("project_list"."owner_id" = "auth"."uid"()))) AND ("project_permissions"."user_id" = "auth"."uid"()) AND ("project_permissions"."role" = ANY (ARRAY['owner'::"text", 'admin'::"text"]))))));



CREATE POLICY "Allow user to block others" ON "public"."blocked_users" FOR INSERT WITH CHECK (("auth"."uid"() = "blocker_id"));



CREATE POLICY "Allow user to unblock" ON "public"."blocked_users" FOR DELETE USING (("auth"."uid"() = "blocker_id"));



CREATE POLICY "Allow users to view their blocked relationships" ON "public"."blocked_users" FOR SELECT USING ((("auth"."uid"() = "blocker_id") OR ("auth"."uid"() = "blocked_id")));



CREATE POLICY "Allow users to view their own invitations" ON "public"."invitations" FOR SELECT TO "authenticated" USING (("auth"."email"() = "recipient_email"));



CREATE POLICY "Allow users to view their permissions" ON "public"."project_permissions" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Owner Full Access" ON "public"."project_list" USING (("auth"."uid"() = "owner_id")) WITH CHECK (("auth"."uid"() = "owner_id"));



CREATE POLICY "Prevent users from deleting invitations directly" ON "public"."invitations" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Prevent users from updating invitations directly" ON "public"."invitations" FOR UPDATE TO "authenticated" USING (false);



CREATE POLICY "Project owners can manage their own projects." ON "public"."project_list" TO "authenticated" USING (("auth"."uid"() = "created_by"));



CREATE POLICY "Role-Based Access" ON "public"."project_list" USING ((EXISTS ( SELECT 1
   FROM "public"."project_permissions"
  WHERE (("project_permissions"."project_id" = "project_list"."id") AND ("project_permissions"."user_id" = "auth"."uid"()) AND ("project_permissions"."role" = ANY (ARRAY['admin'::"text", 'editor'::"text", 'viewer'::"text"])))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."project_permissions"
  WHERE (("project_permissions"."project_id" = "project_list"."id") AND ("project_permissions"."user_id" = "auth"."uid"()) AND ("project_permissions"."role" = ANY (ARRAY['admin'::"text", 'editor'::"text"]))))));



CREATE POLICY "Users can insert their own profile." ON "public"."profiles" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Users can update own profile." ON "public"."profiles" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") = "id"));



ALTER TABLE "public"."blocked_users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."project_list" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."project_permissions" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


CREATE PUBLICATION "supabase_realtime_messages_publication" WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION "supabase_realtime_messages_publication" OWNER TO "supabase_admin";


ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."project_list";



GRANT ALL ON SCHEMA "backup_data" TO "authenticator";
GRANT USAGE ON SCHEMA "backup_data" TO "anon";
GRANT USAGE ON SCHEMA "backup_data" TO "authenticated";
GRANT USAGE ON SCHEMA "backup_data" TO "service_role";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";




















































































































































































GRANT ALL ON FUNCTION "public"."backup_project_list_changes"() TO "anon";
GRANT ALL ON FUNCTION "public"."backup_project_list_changes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."backup_project_list_changes"() TO "service_role";



GRANT ALL ON FUNCTION "public"."enforce_lowercase_fields"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_lowercase_fields"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_lowercase_fields"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_project_owner"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_project_owner"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_project_owner"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "backup_data"."project_list_backup" TO "authenticator";
GRANT ALL ON TABLE "backup_data"."project_list_backup" TO "anon";
GRANT ALL ON TABLE "backup_data"."project_list_backup" TO "authenticated";
GRANT ALL ON TABLE "backup_data"."project_list_backup" TO "service_role";


















GRANT ALL ON TABLE "public"."blocked_users" TO "anon";
GRANT ALL ON TABLE "public"."blocked_users" TO "authenticated";
GRANT ALL ON TABLE "public"."blocked_users" TO "service_role";



GRANT ALL ON TABLE "public"."connections" TO "anon";
GRANT ALL ON TABLE "public"."connections" TO "authenticated";
GRANT ALL ON TABLE "public"."connections" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."community" TO "anon";
GRANT ALL ON TABLE "public"."community" TO "authenticated";
GRANT ALL ON TABLE "public"."community" TO "service_role";



GRANT ALL ON TABLE "public"."connection_profiles" TO "anon";
GRANT ALL ON TABLE "public"."connection_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."connection_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."invitations" TO "anon";
GRANT ALL ON TABLE "public"."invitations" TO "authenticated";
GRANT ALL ON TABLE "public"."invitations" TO "service_role";



GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



GRANT ALL ON TABLE "public"."project_list" TO "anon";
GRANT ALL ON TABLE "public"."project_list" TO "authenticated";
GRANT ALL ON TABLE "public"."project_list" TO "service_role";



GRANT ALL ON TABLE "public"."project_permissions" TO "anon";
GRANT ALL ON TABLE "public"."project_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."project_permissions" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "backup_data" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "backup_data" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "backup_data" GRANT ALL ON SEQUENCES  TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "backup_data" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "backup_data" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "backup_data" GRANT ALL ON FUNCTIONS  TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "backup_data" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "backup_data" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "backup_data" GRANT ALL ON TABLES  TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
