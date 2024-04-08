# Clickhouse tutorials

In this repository you will find a series of tutorials, described in different [Medium posts](https://medium.com/@brendavarguez21), to integrate [ClickHouse](https://clickhouse.com/) with different tools such as Terraform, dbt, Metabase, etc. The configurations used in these tutorials are completely based on my experience and requirements needed at the time of development. Therefore, I strongly encourage you to use these scripts as guides for your first steps.

### ClickHouse Terraform

In the `clickhouse_terraform` folder you'll find scripts required to integrate ClickHouse with Terraform and Kubernetes through helm charts. For more context feel free to read the original [medium post](https://medium.com/@brendavarguez21/deploying-clickhouse-on-a-kubernetes-cluster-using-terraform-d4e2234c27af)!

### ClickHouse Users

In the `clickhouse_users` folder you can find the original scripts from `clickhouse_terraform` with the necessary modifications to create new users with the required grants according to the needs of each one of them. If you want a detailed explanation of the new configs you can always consult the original post, [Creating multiple users in ClickHouse from Terraform](https://medium.com/@brendavarguez21/creating-multiple-users-in-clickhouse-from-terraform-998ccfa6c44a).

### ClickHouse + dbt

Within the `ch_dbt` folder you will find scripts and files to create, connect and configure your first dbt project with ClickHouse.  Moreover, you will also find some csv files as well as sql script examples for you to create your first dbt seeds and dbt models. For a detailed explanation of the code, please refer to the [part 1](https://medium.com/@brendavarguez21/coding-symphony-unleashing-the-power-of-clickhouse-and-dbt-for-modern-data-analytics-part-1-edaa9ed2a457) and [part 2](https://medium.com/@brendavarguez21/coding-symphony-unleashing-the-power-of-clickhouse-and-dbt-for-modern-data-analytics-part-2-f486f9af54bd) of my medium posts where I provide an easy guide for the ClickHouse + dbt integration.
