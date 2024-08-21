# PowerSync Swift Demo App

A simple Swift app using the PowerSync Swift SDK. Built with KMMBridge + SKIE and using Supabase

<img width="1496" alt="Screenshot 2024-03-13 at 10 30 38" src="https://github.com/powersync-ja/powersync-kotlin-swift-demo/assets/1895233/c717982c-b942-40f2-87f7-848b6e964905">

## Features

- Using PowerSync Kotlin-Swift SDK to perform `read`, `insert`, `update`, and `watch` queries
- Integrates with Supabase via `SupabaseConnector` and email-and-password `auth`

## Set up Supabase Project

Create a new Supabase project, and paste and run the below SQL in the Supabase SQL editor.

It does the following:

1. Create a `todos` table.
2. Create a logical replication publication called `powersync` for  `todos`.

```sql
-- Create tables
create table
  public.todos (
    id uuid not null default gen_random_uuid (),
    description text not null,
    completed boolean not null default false,
    constraint todos_pkey primary key (id)
  ) tablespace pg_default;

-- Create publication for powersync
create publication powersync for table todos;
```

### Set up Supabase User

In your Supabase Dashboard, under "Authentication", click on "Add User" -> "Create new user" and create a user for yourself to test with.

## Set up PowerSync Instance

Create a new PowerSync instance, connecting to the database of the Supabase project (find detailed instructions in the “Connect PowerSync to Your Database” section of our [Supabase setup guide](https://docs.powersync.com/usage/installation/database-setup/supabase#connect-powersync-to-your-database)).

Then deploy the following basic [sync rules](https://docs.powersync.com/usage/sync-rules):

```yaml
bucket_definitions:
  global:
    data:
      - select * from todos
```

## Configure The App

Open the project in XCode.

Open the “_Secrets” file and fill in the placeholder values.

You can find the Supabase values under "Project Settings" -> "API" in your Supabase dashboard — under the "URL" section, and anon key under "Project API keys".

You can obtain your PowerSync Instance URL by following these steps:

- In the project tree on the PowerSync dashboard, right click on the instance you created earlier
- Click "Edit instance"
- Click on "Instance URL" to copy the value

## Configure Xcode access to SDK binary

The below steps are required by [KMMBridge](https://touchlab.co/quick-start-with-kmmbridge-1-hour-tutorial#configure-xcode-clients):

### Create GitHub Personal Access Token (PAT)

In your GitHub:

1. Under your user account, navigate to “Settings” -> “Developer Settings” -> “Personal access tokens” -> “Tokens (classic)”
2. Click “Generate new token” and select “Generate new token (classic)”
3. Given the token a name e.g. PowerSync XCode
4. Set the expiration date to “No expiration”, since we won’t be giving this token any sensitive privileges
5. Under “Select scopes”, enable the “read:packages” checkbox (don’t need “write:packages”)
6. Click Generate Token
7. Copy the value for the next step

### Create .netrc file

1. Create a file `~/.netrc` with the following contents:

```
machine maven.pkg.github.com
  login [your GitHub username]
  password [your PAT from the previous step]
```

### Finish XCode configuration

1. Clear Swift caches
```
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/org.swift.swiftpm
```

2. Run `pod install` in the project root

3. In Xcode:
- Reset Packages: File -> Packages -> Reset Package Caches
- Clean Build: Product -> Clean Build Folder.

## Run project

Build the project, launch the app and sign in with the test user you created in Supabase earlier.
