# flask-template

A template project with:

- Python 3.13
- Flask 3.1.0

## Making it your own

Click on the **"Use this template"** button on GitHub and create a new repository.

Clone your new repository.

Ensure that you have GNU or BSD Make installed.

Run the `rename` Makefile target to replace all instances of `flask_template` and `flask-template` with your project's name in snake_case and kebab-case, respectively.

```bash
make rename PROJECT_NAME=my_project_name_with_underscores
```

## Running the project locally

Ensure that you have the following installed:

- GNU or BSD Make
- Docker
- Docker Compose

Build your development environment.

```bash
make build
```

Run your development environment.

```bash
make start
```

Open an interactive shell into the Docker container that contains the Flask project.

```bash
make sh
```
Spin up the development server.

```bash
# Inside the Flask Docker container
flaskrun
```

The Flask app will be available at http://localhost:8000/.

Check out the [Makefile](Makefile) for other useful commands.
