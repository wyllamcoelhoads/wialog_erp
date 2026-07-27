🚚 WiaLog ERP

O WiaLog ERP é um sistema de gestão de frotas e controle financeiro desenvolvido em Flutter. O objetivo principal deste MVP é fornecer uma solução robusta e local (On-Premise) para pequenas e médias empresas de transporte, garantindo o controle operacional de manutenções e o fluxo de caixa.

Nesta primeira fase, a aplicação tem como alvo exclusivo o ambiente Windows Desktop, com a arquitetura preparada para futura expansão mobile.

✨ Funcionalidades (MVP)

🔐 Controle de Acesso (RBAC): Perfis de Administrador, Fiscal, Financeiro e Atendente.

📊 Dashboard Executivo: Visão geral com KPIs de veículos ativos, em manutenção e fluxo de caixa do mês.

🚛 Gestão de Frotas: Cadastro de veículos e acompanhamento de status operacional.

🛠️ Ordens de Manutenção: Registro de manutenções preventivas e corretivas atreladas à frota.

💰 Módulo Financeiro: Controle integrado de contas a pagar e a receber.

🏗️ Arquitetura e Tecnologias

O projeto foi estruturado seguindo os princípios da Clean Architecture, dividindo a aplicação em camadas para garantir baixo acoplamento e alta testabilidade.

Framework: Flutter (Desktop)

Gerência de Estado: BLoC (Business Logic Component)

Injeção de Dependência: GetIt

Programação Funcional: fpdart (para tratamento de erros com Either)

Banco de Dados: PostgreSQL / SQL Server (Local)

Estrutura de Diretórios

O projeto é modularizado por Features, onde cada funcionalidade possui suas próprias camadas:

lib/
├── core/             # Código compartilhado (erros, rede, utilitários)
└── features/         # Módulos independentes do sistema
    ├── auth/         # Autenticação e permissões
    ├── dashboard/    # Tela inicial e KPIs
    ├── finance/      # Contas a pagar e receber
    └── fleet/        # Controle de frota e manutenção
        ├── data/         # Repositórios de dados, Models e DataSources
        ├── domain/       # UseCases e Entidades (Regra de Negócio Pura)
        └── presentation/ # BLoCs, Pages e Widgets (UI)


🚀 Como Executar o Projeto

Pré-requisitos

Flutter SDK (versão atualizada).

Suporte para compilação Windows ativado no Flutter.

Banco de dados local configurado (PostgreSQL/SQL Server).

Passos

Clone o repositório:

git clone https://github.com/seu-usuario/wialog_erp.git


Acesse a pasta do projeto:

cd wialog_erp


Instale as dependências:

flutter pub get


Execute o aplicativo no ambiente Windows:

flutter run -d windows


🛠️ Padrão de Commits

Este projeto adota o padrão Conventional Commits para manter o histórico de versionamento limpo e rastreável. Por favor, utilize os seguintes prefixos ao realizar commits:

feat: - Uma nova funcionalidade.

fix: - Correção de um bug.

docs: - Alterações apenas na documentação.

style: - Alterações de formatação (espaços, vírgulas, etc) que não afetam o código.

refactor: - Uma alteração de código que não corrige um bug nem adiciona uma feature.

chore: - Atualizações de tarefas de build, configurações de pacotes, etc.

Exemplo: git commit -m "feat: adiciona dashboard com indicadores de frota"