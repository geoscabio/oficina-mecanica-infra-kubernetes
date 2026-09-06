# Oficina Mecanica Infra Kubernetes

Repositorio da esteira Kubernetes da Fase 3 do Tech Challenge.

## Objetivo

Provisionar e operar a base Kubernetes da solucao da Oficina Mecanica em AWS, mantendo o mesmo padrao de CI/CD usado na API e nas demais esteiras de infraestrutura.

## Responsabilidades

- Criar o cluster EKS de `development`.
- Criar o Managed Node Group.
- Criar o repositorio ECR usado pela imagem da API.
- Consumir os outputs da VPC publicados no SSM Parameter Store.
- Publicar outputs de Kubernetes e ECR no SSM para as proximas esteiras.
- Controlar `apply` e `destroy` por workflow com validacoes reais na AWS.

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

## Workflows

| Workflow | Responsabilidade |
| --- | --- |
| `ci.yml` | Validar PR, Git Flow e Terraform quando houver mudanca deployable. |
| `cd-development.yml` | Detectar mudanca deployable em `develop`, chamar o deploy real e abrir PR para `release` quando habilitado. |
| `aws-deploy.yml` | Resolver `apply`/`destroy`, gerar plano, aplicar Terraform, validar AWS e publicar state em cache. |
| `cd-release.yml` | Registrar deploy logico em `homologation` e abrir PR para `main` quando habilitado. |
| `cd-production.yml` | Registrar deploy logico em `production`. |

O desenho dos workflows segue a API. A diferenca fica apenas no conteudo tecnico de cada job: aqui a validacao e o deploy sao de Terraform/EKS/ECR.

## Dependencia da VPC

Antes de aplicar Kubernetes, a VPC precisa estar pronta e publicar os parametros abaixo:

| Parametro SSM | Uso |
| --- | --- |
| `/oficina-mecanica/development/status/vpc` | Deve estar com valor `ready`. |
| `/oficina-mecanica/development/vpc/vpc_id` | VPC usada pelo EKS. |
| `/oficina-mecanica/development/vpc/private_subnet_ids` | Subnets privadas usadas pelo cluster e pelo node group. |

## Outputs publicados

Depois do apply, esta esteira publica:

| Parametro SSM | Uso |
| --- | --- |
| `/oficina-mecanica/development/status/kubernetes` | Marca Kubernetes como pronto para dependentes. |
| `/oficina-mecanica/development/kubernetes/cluster_name` | Nome do cluster EKS. |
| `/oficina-mecanica/development/kubernetes/cluster_endpoint` | Endpoint do cluster EKS. |
| `/oficina-mecanica/development/kubernetes/cluster_security_group_id` | Security group principal do cluster. |
| `/oficina-mecanica/development/kubernetes/node_group_name` | Nome do Managed Node Group. |
| `/oficina-mecanica/development/kubernetes/ecr_repository_name` | Nome do ECR da API. |
| `/oficina-mecanica/development/kubernetes/ecr_repository_url` | URL do ECR da API. |

## Variaveis e secrets

Configurar no GitHub Environment `development` antes do primeiro merge para `develop` que execute deploy real.

Environment secrets:

| Nome | Uso |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | Credencial AWS Academy. |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS Academy. |
| `AWS_SESSION_TOKEN` | Token de sessao AWS Academy. |

Environment variables:

| Nome | Valor sugerido |
| --- | --- |
| `AWS_REGION` | `us-east-1` |
| `EKS_CLUSTER_ROLE_NAME` | `LabRole` quando o lab usar role unica, ou a role EKS indicada pela AWS Academy. |
| `EKS_NODE_ROLE_NAME` | `LabRole` quando o lab usar role unica, ou a role de nodes indicada pela AWS Academy. |
| `AUTO_PR_ENABLED` | `true` somente quando quiser abrir PRs automaticos de promocao. |
| `RELEASE_BRANCH` | `release` |

## Controle apply/destroy

O deploy real e controlado por:

```text
infra/terraform/environments/dev/terraform-action.env
```

Para subir ou atualizar Kubernetes:

```env
TERRAFORM_ACTION=apply
```

Para destruir Kubernetes:

```env
TERRAFORM_ACTION=destroy
```

Regra de seguranca: `destroy` so e aceito quando `terraform-action.env` muda no proprio PR/merge. Isso evita destruir recursos em execucoes futuras por acidente.

## Execucao local

Validar formatacao:

```powershell
terraform fmt -check -recursive infra/terraform
```

Validar Terraform:

```powershell
terraform -chdir=infra/terraform/environments/dev init -backend=false
terraform -chdir=infra/terraform/environments/dev validate
```

Gerar plano local, depois de configurar credenciais AWS e variaveis obrigatorias:

```powershell
$env:TF_VAR_eks_cluster_role_name = "LabRole"
$env:TF_VAR_eks_node_role_name = "LabRole"
terraform -chdir=infra/terraform/environments/dev plan
```

## Ordem da Fase 3

Esta esteira deve rodar depois da VPC e antes do deploy da API no EKS.

```text
infra-vpc -> infra-kubernetes -> api -> infra-api-gateway
```

RDS e Kubernetes podem evoluir em paralelo depois que a VPC estiver disponivel.
