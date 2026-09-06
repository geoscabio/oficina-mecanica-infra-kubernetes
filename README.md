# ☸️ Oficina Mecânica Infra Kubernetes

Repositório da esteira Kubernetes da Fase 3 do Tech Challenge.

## 🎯 Objetivo

Provisionar e operar a base Kubernetes da solução da Oficina Mecânica em AWS, mantendo o mesmo padrão de CI/CD usado na API e nas demais esteiras de infraestrutura.

## 📌 Responsabilidades

- Criar o cluster EKS de `development`.
- Criar o Managed Node Group.
- Criar o repositório ECR usado pela imagem da API.
- Consumir os outputs da VPC publicados no SSM Parameter Store.
- Publicar outputs de Kubernetes e ECR no SSM para as próximas esteiras.
- Controlar `apply` e `destroy` por workflow com validações reais na AWS.

## 🔀 Fluxo Git

```text
branch de trabalho -> PR develop -> deploy development -> PR release -> deploy homologation -> PR main -> deploy production
```

Branches protegidas esperadas:

- `develop`
- `release`
- `release/*`
- `main`

Toda mudança deve passar por PR, CI, aprovação e Quality gate. Maintainers e admins podem usar bypass somente via PR quando necessário.

## 🔁 Workflows

| Workflow | Responsabilidade |
| --- | --- |
| `🧪 CI Development` | Validar PR para `develop`, Git Flow e Terraform quando houver mudança deployable. |
| `🔎 CI Release` | Validar PR para `release` ou `release/**`, Git Flow e Terraform quando houver mudança deployable. |
| `🛡️ CI Production` | Validar PR para `main`, Git Flow e Terraform quando houver mudança deployable. |
| `🚀 CD Development` | Detectar mudança deployable em `develop`, chamar o deploy real e abrir PR para `release` quando habilitado. |
| `☁️ AWS Deploy` | Resolver `apply`/`destroy`, gerar plano, aplicar Terraform, validar AWS e publicar state em cache. |
| `🔀 CD Release` | Registrar deploy lógico em `homologation` e abrir PR para `main` quando habilitado. |
| `🏁 CD Production` | Registrar deploy lógico em `production`. |

O desenho dos workflows segue a API. A diferença fica apenas no conteúdo técnico de cada job: aqui a validação e o deploy são de Terraform/EKS/ECR.

## 🌐 Dependência da VPC

Antes de aplicar Kubernetes, a VPC precisa estar pronta e publicar os parâmetros abaixo:

| Parâmetro SSM | Uso |
| --- | --- |
| `/oficina-mecanica/development/status/vpc` | Deve estar com valor `ready`. |
| `/oficina-mecanica/development/vpc/vpc_id` | VPC usada pelo EKS. |
| `/oficina-mecanica/development/vpc/private_subnet_ids` | Subnets privadas usadas pelo cluster e pelo node group. |

## 📤 Outputs publicados

Depois do apply, esta esteira publica:

| Parâmetro SSM | Uso |
| --- | --- |
| `/oficina-mecanica/development/status/kubernetes` | Marca Kubernetes como pronto para dependentes. |
| `/oficina-mecanica/development/kubernetes/cluster_name` | Nome do cluster EKS. |
| `/oficina-mecanica/development/kubernetes/cluster_endpoint` | Endpoint do cluster EKS. |
| `/oficina-mecanica/development/kubernetes/cluster_security_group_id` | Security group principal do cluster. |
| `/oficina-mecanica/development/kubernetes/node_group_name` | Nome do Managed Node Group. |
| `/oficina-mecanica/development/kubernetes/ecr_repository_name` | Nome do ECR da API. |
| `/oficina-mecanica/development/kubernetes/ecr_repository_url` | URL do ECR da API. |

## 🔐 Variáveis e secrets

Configurar no GitHub Environment `development` antes do primeiro merge para `develop` que execute deploy real.

Environment secrets:

| Nome | Uso |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | Credencial AWS Academy. |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS Academy. |
| `AWS_SESSION_TOKEN` | Token de sessão AWS Academy. |

Environment variables:

| Nome | Valor sugerido |
| --- | --- |
| `AWS_REGION` | `us-east-1` |
| `EKS_CLUSTER_ROLE_NAME` | `LabRole` quando o lab usar role única, ou a role EKS indicada pela AWS Academy. |
| `EKS_NODE_ROLE_NAME` | `LabRole` quando o lab usar role única, ou a role de nodes indicada pela AWS Academy. |
| `AUTO_PR_ENABLED` | `true` somente quando quiser abrir PRs automáticos de promoção. |
| `RELEASE_BRANCH` | `release` |

## 🧭 Controle apply/destroy

O deploy real é controlado por:

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

Regra de segurança: `destroy` só é aceito quando `terraform-action.env` muda no próprio PR/merge. Isso evita destruir recursos em execuções futuras por acidente.

## 🧪 Execução local

Validar formatação:

```powershell
terraform fmt -check -recursive infra/terraform
```

Validar Terraform:

```powershell
terraform -chdir=infra/terraform/environments/dev init -backend=false
terraform -chdir=infra/terraform/environments/dev validate
```

Gerar plano local, depois de configurar credenciais AWS e variáveis obrigatórias:

```powershell
$env:TF_VAR_eks_cluster_role_name = "LabRole"
$env:TF_VAR_eks_node_role_name = "LabRole"
terraform -chdir=infra/terraform/environments/dev plan
```

## 🗓️ Ordem da Fase 3

Esta esteira deve rodar depois da VPC e antes do deploy da API no EKS.

```text
infra-vpc -> infra-kubernetes -> api -> infra-api-gateway
```

RDS e Kubernetes podem evoluir em paralelo depois que a VPC estiver disponível.
