# PowerSync Swift Demo App

A simple Swift app using the PowerSync Swift SDK. Built with KMMBridge + SKIE and using Supabase

<img width="1496" alt="Screenshot 2024-03-13 at 10 30 38" src="https://github.com/powersync-ja/powersync-kotlin-swift-demo/assets/1895233/c717982c-b942-40f2-87f7-848b6e964905">

## Features

- Using PowerSync Kotlin-Swift SDK to perform `read`, `insert`, `update`, and `watch` queries
- Integrates with Supabase via `SupabaseConnector` and email-and-password `auth` 

## Set up Supabase Project

Create a new Supabase project, and paste and run the below SQL  in the Supabase SQL editor.

It does the following:

1. Create a `todos` table.
2. Create a logical replication publication called `powersync` for  `todos`.

```sql
 1 -- Create tables
 2 create table
 3   public.todos (
 4     id uuid not null default gen_random_uuid (),
 5     description text not null,
 6     completed boolean not null default false,
 7     constraint todos_pkey primary key (id),
 8   ) tablespace pg_default;
 9
10 -- Create publication for powersync
11 create publication powersync for table todos;
```

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

TODO