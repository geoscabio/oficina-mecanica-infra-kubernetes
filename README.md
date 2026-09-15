# Oficina Mecânica — Infraestrutura Kubernetes

EKS, node group, ECR, NLB interno e contratos do serviço NodePort da solução.
A visão geral está no [README da API](https://github.com/geoscabio/oficina-mecanica-api#readme).

## Responsabilidade e arquitetura

O apply principal cria somente a infraestrutura base: EKS, node group, ECR e os
contratos NLB existentes. A API não usa Service `LoadBalancer` público:

`API Gateway -> VPC Link -> NLB interno -> target group -> EKS NodePort -> pods`

## Repositórios da solução

| Repositório | Responsabilidade |
|---|---|
| [API](https://github.com/geoscabio/oficina-mecanica-api) | Aplicação .NET e documentação principal. |
| [Auth Lambda](https://github.com/geoscabio/oficina-mecanica-auth-lambda) | Autenticação e JWT. |
| [VPC](https://github.com/geoscabio/oficina-mecanica-infra-vpc) | Rede compartilhada. |
| [Kubernetes](https://github.com/geoscabio/oficina-mecanica-infra-kubernetes) | EKS, ECR, NLB interno e NodePort. |
| [RDS](https://github.com/geoscabio/oficina-mecanica-infra-rds) | SQL Server privado. |
| [API Gateway](https://github.com/geoscabio/oficina-mecanica-infra-api-gateway) | Entrada HTTP e VPC Link. |

## Configuração, secrets e contratos

| Nome | Tipo e escopo | Obrigatório | Finalidade |
|---|---|---:|---|
| `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` | GitHub Environment Secrets (`development`) | Sim | Credenciais AWS. |
| `AWS_SESSION_TOKEN` | GitHub Environment Secret (`development`) | Quando temporário | Sessão AWS. |
| `AWS_REGION` | GitHub Variable | Sim | Região AWS. |
| `EKS_CLUSTER_ROLE_NAME`, `EKS_NODE_ROLE_NAME` | GitHub Variables | Sim | Roles externas do cluster e dos nós. |
| `DD_API_KEY` | GitHub Environment Secret (`development`) | Apenas workflow Datadog | API key Datadog, não App Key; criar em Datadog > Organization Settings > API Keys e nunca versionar. |
| `DD_SITE` | GitHub Environment Variable (`development`) | Não | Site da organização; fallback `datadoghq.com`. |
| `AUTO_PR_ENABLED`, `RELEASE_BRANCH` | GitHub Variables | Não | Promoção. |

Consome `/oficina-mecanica/development/status/vpc`, `/vpc/vpc_id` e
`/vpc/private_subnet_ids`. Publica `cluster_name`, `cluster_endpoint`,
`cluster_security_group_id`, `node_group_name`, `ecr_repository_name`,
`ecr_repository_url`, `api_internal_node_port`, `internal_nlb_security_group_id`,
`internal_nlb_listener_arn` e `status/kubernetes` sob
`/oficina-mecanica/development`.

## CI/CD e deploy base

`aws-deploy.yml` preserva o fluxo atual de plan/apply/destroy da infraestrutura
base. Para validação local, execute `terraform fmt -check`, `terraform validate`
e `terraform plan` no diretório Terraform. O deploy de observabilidade não altera
essa esteira.

## 🐕 Observabilidade Datadog

O workflow manual **`🐕 Observabilidade Datadog`** é separado do apply EKS e só
deve ser executado após o cluster estar `ACTIVE`. Ele instala Agent e Cluster
Agent, logs, métricas Kubernetes e receptor APM com o chart oficial
`datadog/datadog`; a chave é materializada somente como o Secret Kubernetes
`datadog-secret`, sem Terraform state ou hardcode.

Passos do workflow:

1. Baixa o repositório.
2. Configura as credenciais AWS acima.
3. Instala `kubectl`.
4. Instala Helm.
5. Confirma que `DD_API_KEY` existe no Environment `development`.
6. Lê `/oficina-mecanica/development/kubernetes/cluster_name` no SSM e exige EKS `ACTIVE`.
7. Executa `aws eks update-kubeconfig`.
8. Valida a API Kubernetes com `/readyz`.
9. Confirma permissões para namespace, secrets, ClusterRole e ClusterRoleBinding.
10. Cria o namespace `datadog` e cria/atualiza `datadog-secret`.
11. Adiciona o repositório Helm, renderiza e aplica o chart fixado, aguardando Agent e Cluster Agent.

As credenciais AWS usadas nessa execução são `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` quando houver sessão temporária e
`AWS_REGION`. A identidade precisa ler o parâmetro SSM, descrever o EKS e obter
acesso Kubernetes compatível com as autorizações validadas pelo workflow.

## Validações e documentação

Além dos checks do workflow, use `git diff --check`. Referências:
[API principal](https://github.com/geoscabio/oficina-mecanica-api#readme),
[Amazon EKS](https://docs.aws.amazon.com/eks/) e
[Datadog Helm chart](https://github.com/DataDog/helm-charts/tree/main/charts/datadog).
