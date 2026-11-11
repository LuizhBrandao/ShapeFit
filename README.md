# ShapeFit

Plataforma integrada de engenharia de software para prescrição científica de rotinas de treino, gestão de periodização por mesociclos e acompanhamento de hipertrofia muscular.

A solução é composta por um backend robusto em .NET 10 estruturado sob os princípios de Domain-Driven Design (DDD) e Clean Architecture, aliado a uma aplicação cliente multiplataforma em Flutter (Android, iOS e Web).

---

## Índice

- Visão Geral do Projeto
- Princípios Arquiteturais do Backend
- Arquitetura do Frontend Mobile
- Matriz de Ambientes (Dev, Staging, Prod)
- Estrutura do Repositório
- Tecnologias Utilizadas
- Como Executar a Solução Localmente
- Execução de Testes Automatizados
- Integração e Entrega Contínua (CI/CD)

---

## Visão Geral do Projeto

O ShapeFit foi concebido para eliminar abordagens empíricas no planejamento de treinos resistidos, aplicando modelos matemáticos e metodologias científicas de sobrecarga progressiva:

- Prescrição Científica de Treino: cálculo de volume (séries semanais por grupamento muscular) e divisões estruturadas (Full Body, Upper/Lower, Push/Pull/Legs, Arnold Split).
- Gestão de Mesociclos: acompanhamento sistemático de blocos de 30 treinos com progressão de sobrecarga, calibração de RPE/RIR e controle de esforço.
- Registro em Tempo Real: interface mobile interativa com cronômetro de descanso, pré-preenchimento baseado na última performance e histórico detalhado.
- Análise Biomecânica: guias de execução e ilustrações vetoriais para padronização técnica dos movimentos.

---

## Princípios Arquiteturais do Backend

O backend adota Domain-Driven Design (DDD) rigoroso com separação estrita em quatro camadas:

1. ShapeFit.Domain (Núcleo do Domínio)
   - Totalmente isolado de frameworks e dependências externas de infraestrutura.
   - Agregados e Entidades: Mesocycle, RoutineTemplate, RoutineDay, RoutineExercise, WorkoutSession, WorkoutExerciseLog, WorkoutSetLog.
   - Objetos de Valor (Value Objects): Weight, RepRange, SessionVolumeCalibration (imutabilidade estrita e validação de invariantes).
   - Serviços de Domínio: OneRepMaxCalculator (fórmulas de Brzycki e Epley), RoutinePrescriptionService (distribuição de volume e seleção de exercícios por grupamento), VolumeCalibrationService.
   - Eventos de Domínio: MesocycleCompletedEvent para disparo de notificações e transições de ciclo.

2. ShapeFit.Application (Orquestração e Casos de Uso)
   - Implementação do padrão CQRS com MediatR.
   - Commands: PrescribeRoutineCommand, LogWorkoutCommand (com auto-incremento do mesociclo ativo).
   - Queries: GetActiveRoutineQuery, GetMesocycleProgressQuery, GetLastPerformanceQuery.
   - Validação de entrada via FluentValidation com regras de negócio pré-execução.

3. ShapeFit.Infrastructure (Persistência e Recursos Externos)
   - Persistência relacional em PostgreSQL utilizando Dapper Micro-ORM para consultas de alta performance.
   - Estratégia de cache em dois níveis (Hot Cache em memória e Redis distribuído).
   - Logging estruturado com CorrelationId propagado em todos os fluxos.

4. ShapeFit.Api (Interface de Entrada / Minimal APIs)
   - Endpoints modularizados utilizando ASP.NET Core Minimal APIs com retorno tipado (TypedResults).
   - Documentação interativa via OpenAPI e Scalar API Reference.
   - Middleware global de rastreabilidade (CorrelationIdMiddleware) e CORS configurado por ambiente.

---

## Arquitetura do Frontend Mobile

O projeto shapefit_mobile é desenvolvido em Flutter com gestão de estado reativa baseada no padrão Provider:

- Entry Points Multi-Ambiente: separação em `main_dev.dart`, `main_staging.dart` e `main_prod.dart`.
- AppConfig Singleton: injeção automática da URL base da API e parâmetros de ambiente em tempo de compilação via flag `--dart-define=ENV=...`.
- Camada de Serviços: `WorkoutApiService` centraliza as chamadas REST com headers padronizados e tratamento de conectividade.
- Sincronização de Dados: DTOs tipados que espelham com precisão os contratos da API em C#.

---

## Matriz de Ambientes (Dev, Staging, Prod)

| Dimensão | Development (Dev) | Staging (Homologação) | Production (Produção) |
| :--- | :--- | :--- | :--- |
| Branch Git | develop | staging | main |
| Porta HTTP API | 5198 | 5199 | 5200 |
| Banco de Dados | shapefit_dev (Porta 5433) | shapefit_staging (Porta 5434) | shapefit_prod (Porta 5432) |
| Redis Cache | localhost:6379 | localhost:6380 | Cluster seguro com SSL |
| Documentação API | Scalar / OpenAPI Ativado | Scalar / OpenAPI Ativado | Desativado / Restrito |
| Nível de Log | Debug / Information | Information / Warning | Warning / Error |
| Entry Point Mobile | lib/main_dev.dart | lib/main_staging.dart | lib/main_prod.dart |

---

## Estrutura do Repositório

```text
ShapeFit/
|-- .github/
|   `-- workflows/               # Pipelines de CI/CD (GitHub Actions)
|-- src/
|   |-- ShapeFit.Domain/         # Entidades, Value Objects e Serviços de Domínio
|   |-- ShapeFit.Application/    # Commands, Queries, Handlers e Validações CQRS
|   |-- ShapeFit.Infrastructure/ # Acesso a dados com Dapper, Migrations e Cache
|   `-- ShapeFit.Api/            # Minimal APIs, Middlewares e Configurações
|-- tests/
|   |-- ShapeFit.Domain.Tests/         # Testes unitários do modelo de domínio
|   |-- ShapeFit.Application.Tests/    # Testes unitários e de fluxo de comandos
|   `-- ShapeFit.Infrastructure.Tests/ # Testes de persistência e repositórios
|-- shapefit_mobile/             # Aplicativo Flutter (Mobile e Web)
|-- docker-compose.yml           # Infraestrutura local de Desenvolvimento
|-- docker-compose.staging.yml   # Infraestrutura de Homologação
|-- docker-compose.prod.yml      # Infraestrutura de Produção
|-- .env.example                 # Modelo de variáveis de ambiente
`-- README.md                    # Documentação principal da solução
```

---

## Tecnologias Utilizadas

### Backend
- .NET 10 / C# 13
- ASP.NET Core Minimal APIs
- MediatR (CQRS)
- FluentValidation
- Dapper Micro-ORM
- PostgreSQL
- StackExchange.Redis
- Scalar API Reference / OpenAPI

### Frontend
- Flutter 3.x / Dart 3.x
- Provider (Gerenciamento de Estado)
- HTTP Client
- SQLite (Persistência local)

### Infraestrutura e DevOps
- Docker e Docker Compose
- GitHub Actions (CI/CD)
- GitHub Pages

---

## Como Executar a Solução Localmente

### Pré-requisitos
- .NET SDK 10.0 ou superior instalado.
- Docker e Docker Compose instalados e em execução.
- Flutter SDK instalado (para execução do aplicativo cliente).

### Passo 1: Subir a Infraestrutura (Banco e Cache)
No terminal, execute o Docker Compose para o ambiente desejado:

```bash
# Ambiente de Desenvolvimento
docker compose -f docker-compose.yml up -d
```

### Passo 2: Executar a API .NET
Acesse a pasta raiz do projeto e execute:

```bash
# Executar no perfil de Desenvolvimento (porta 5198)
dotnet run --project src/ShapeFit.Api --launch-profile Development
```

Acesse a documentação interativa no navegador:
`http://localhost:5198/scalar/v1`

Para testar a integridade da API:
`GET http://localhost:5198/api/health`

### Passo 3: Executar o Aplicativo Flutter
Em um novo terminal, entre na pasta do app mobile e inicie o projeto:

```bash
cd shapefit_mobile
flutter pub get

# Executar conectado ao ambiente de desenvolvimento
flutter run -t lib/main_dev.dart
```

---

## Execução de Testes Automatizados

O projeto conta com suítes de testes cobrindo as camadas de domínio, aplicação e infraestrutura:

```bash
# Executar todos os testes da solução
dotnet test

# Executar com relatório detalhado
dotnet test --logger "console;verbosity=normal"
```

---

## Integração e Entrega Contínua (CI/CD)

O ciclo de vida do código é governado por três pipelines do GitHub Actions:

- ci.yml: Disparado em pull requests e pushes para develop, staging e main. Compila o backend em .NET 10, executa todos os testes automatizados e compila a aplicação Flutter.
- cd-staging.yml: Disparado em pushes na branch staging. Gera o build de publicação da API e artefatos de homologação.
- cd-production.yml: Disparado em pushes na branch main. Prepara a versão de produção e realiza o deploy da versão Web no GitHub Pages.
