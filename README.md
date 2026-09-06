# Oficina Mecanica Infra Kubernetes

Repositorio da esteira Kubernetes da Fase 3 do Tech Challenge.

## Objetivo

Provisionar e operar a base Kubernetes da solucao da Oficina Mecanica em AWS, mantendo o mesmo padrao de CI/CD usado na API e nas demais esteiras de infraestrutura.

## Escopo

- Cluster EKS de development.
- Managed Node Group.
- Repositorio ECR da API.
- Publicacao de outputs no SSM Parameter Store.
- Guardrails de apply/destroy pela esteira.

## Fluxo Git

```text
branch de trabalho -> PR develop -> deploy development -> PR release -> deploy homologation -> PR main -> deploy production
```

Branches protegidas esperadas:

- `develop`
- `release`
- `release/*`
- `main`

Toda mudanca deve passar por PR, CI, aprovacao e Quality gate. Maintainers e admins podem usar bypass somente via PR quando necessario.

## Status

Bootstrap inicial do repositorio. A implementacao Terraform e os workflows de CD entram por PR para `develop`, sem executar apply durante a preparacao.
