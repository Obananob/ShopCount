-- Create a trigger function to automatically assign 'owner' role to new users
CREATE OR REPLACE FUNCTION public.handle_new_user_role()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_roles (user_id, role, owner_id)
  VALUES (NEW.id, 'owner', NEW.id);
  RETURN NEW;
END;
$$;

-- Create trigger to assign role after user is created
CREATE TRIGGER on_auth_user_created_assign_role
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_role();

-- Also insert owner role for existing users who don't have any role yet
INSERT INTO public.user_roles (user_id, role, owner_id)
SELECT p.id, 'owner', p.id
FROM profiles p
LEFT JOIN user_roles ur ON p.id = ur.user_id
WHERE ur.user_id IS NULL;