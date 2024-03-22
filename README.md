# On-Chain Access Control

A proof-of-concept for SSI-oriented, on-chain access control.
Smart contract managed roles, based on anonymous credentials that combine verifiable credentials and zero-knowledge proof systems.

[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)

## Getting Started

### Prerequisites

1. [Install Bazel](https://bazel.build/install)
2. [Install Docker](https://docs.docker.com/get-docker/)
3. [Install Go](https://golang.org/doc/install)
4. [Install Node.js](https://nodejs.org/en/download)
5. [Install pnpm](https://pnpm.io/installation)
6. Install [jq](https://jqlang.github.io/jq/)

    **Ubuntu**
    ```bash
    sudo apt-get install jq
    ```
    **Brew (Mac)**
    ```bash
    brew install jq
    ```
    **Choco (Windows)**
    ```bash
    choco install jq -y
    ```
7. [Install ZoKrates](https://zokrates.github.io/gettingstarted.html#installation)

### Installation

- Build the Bazel targets.
  ```bash
  make build
  ```
  
- Install the Node.js dependencies.
  ```bash
  pnpm install
  ```
  
- Create your .env file for each service in [./usecase/](./usecase/):
  ```bash
  cp .env.example .env
  ```
  
- Spin up the required instances for [./usecase/](./usecase/):
  ```bash
  cd ./usecase && docker compose up -d
  ```
  
- Run the usecase services.
  ```bash
  make run-accreditation_body
  make run-verification_body
  make run-project_operator
  ```

## Zokrates

### Usage via Docker
A sample policy [supplier_agreement.zok](./usecase/component_supplier/code/supplier_agreement.zok) with verification function is already created. 

From root dir, start a docker container for zokrates cli
```
./dev/zokrates/run_docker.sh
```
Generate required sample zk artifacts
```
./app/setup.sh <path_to_code_file> <path_to_out_dir> <witness_args>
```
For example for the provided component supplier
```
./app/setup.sh /app/usecase/component_supplier/code/supplier_agreement.zok /app/usecase/component_supplier/gen 2 4
```

## Commit Guidelines

This repo is set up to use [AngularJS's commit message convention](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines).

### Commit Message Format
Each commit message consists of a **header**, a **body** and a **footer**.  The header has a special
format that includes a **type**, a **scope** and a **subject**:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The **header** is mandatory and the **scope** of the header is optional.

Any line of the commit message cannot be longer than 100 characters! This allows the message to be easier
to read on GitHub as well as in various git tools.

### Type
Must be one of the following:

* **feat**: A new feature
* **fix**: A bug fix
* **docs**: Documentation only changes
* **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing
  semi-colons, etc)
* **refactor**: A code change that neither fixes a bug nor adds a feature
* **perf**: A code change that improves performance
* **test**: Adding missing or correcting existing tests
* **chore**: Changes to the build process or auxiliary tools and libraries such as documentation
  generation

For more information, head over to [AngularJS's Commit Guidelines](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines)
