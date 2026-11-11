# ShapeFit Mobile

Aplicativo cliente multiplataforma da solução ShapeFit, desenvolvido em Flutter para Android, iOS e Web.

O aplicativo oferece uma experiência completa para execução e rastreamento de treinos, gestão de mesociclos de hipertrofia, sincronização automática com a API backend e orientações biomecânicas para execução técnica dos exercícios.

---

## Índice

- Funcionalidades Principais
- Arquitetura e Organização de Código
- Configuração de Múltiplos Ambientes
- Requisitos de Ambiente
- Como Executar Localmente
- Testes Automatizados e Análise Estática
- Integração com a API Backend

---

## Funcionalidades Principais

- Prescrição Inteligente de Treino: seleção de divisão muscular (Full Body, Upper/Lower, Push/Pull/Legs, Arnold Split), definição de dias de treino semanais e calibração de volume.
- Gestão de Mesociclo: acompanhamento visual do bloco de 30 treinos com contagem de sessões concluídas e cálculo de progresso percentual.
- Sessão de Treino Ativa:
  - Registro de carga em quilogramas (kg) e repetições executadas.
  - Classificação de séries (Aquecimento, Feeder Set, Série de Trabalho).
  - Cronômetro regressivo para controle de tempo de descanso entre séries.
  - Pré-preenchimento automático dos dados da última sessão para facilitar a progressão de carga.
- Guia Biomecânico e Execução:
  - Visualização gráfica dos padrões de movimento.
  - Modal com instruções técnicas de postura, pegada e respiração.
- Calendário e Histórico de Treinos: visualização cronológica de treinos realizados e métricas de consistência.

---

## Arquitetura e Organização de Código

O projeto segue princípios de separação de responsabilidades e gerenciamento de estado previsível via Provider:

```text
lib/
|-- config/
|   `-- app_config.dart                     # Singleton de configuração de ambiente (Dev, Staging, Prod)
|-- models/
|   |-- routine_dto_models.dart             # Contratos DTO sincronizados com o backend C#
|   |-- workout_enums.dart                  # Enums de divisão muscular e tipos de série
|   |-- workout_models.dart                 # Modelos locais de treino, exercício e série
|   |-- custom_routine_model.dart           # Modelo para customização manual de rotinas
|   |-- exercise_instruction.dart           # Modelos com instruções técnicas de execução
|   `-- beginner_exercise_guide.dart        # Guia didático para praticantes iniciantes
|-- providers/
|   `-- active_workout_provider.dart        # Gerenciamento de estado da sessão de treino e sincronização
|-- screens/
|   |-- home_screen.dart                    # Dashboard principal com resumo do mesociclo e treinos
|   |-- active_workout_screen.dart          # Tela de execução do treino com contadores e timers
|   |-- ai_workout_coach_screen.dart        # Assistente de prescrição de fichas conectado à API
|   |-- create_custom_routine_screen.dart   # Interface para montagem manual de ficha
|   `-- workout_history_calendar_screen.dart# Calendário de treinos concluídos
|-- services/
|   `-- workout_api_service.dart            # Comunicação HTTP REST com a API backend
|-- widgets/
|   |-- biomechanical_animation_viewer.dart # Renderizador vetorial de movimento biomecânico
|   `-- exercise_video_modal.dart           # Modal com instruções e demonstração de técnica
|-- main.dart                               # Entry point padrão (fallback para produção)
|-- main_dev.dart                           # Entry point do ambiente de Desenvolvimento
|-- main_staging.dart                       # Entry point do ambiente de Homologação (Staging)
`-- main_prod.dart                          # Entry point do ambiente de Produção
```

---

## Configuração de Múltiplos Ambientes

O aplicativo implementa o padrão multi-target com entry points dedicados e suporte à passagem de variáveis via linha de comando:

### 1. Desenvolvimento (Dev)
- Entry point: `lib/main_dev.dart`
- URL padrão da API: `http://localhost:5198` (Web) ou `http://10.0.2.2:5198` (Emulador Android)
- Identificador visual: Badge DEV exibido no cabeçalho da aplicação.

### 2. Homologação (Staging)
- Entry point: `lib/main_staging.dart`
- URL padrão da API: `http://localhost:5199` (Web) ou `http://10.0.2.2:5199` (Emulador Android)
- Identificador visual: Badge STAGE exibido no cabeçalho da aplicação.

### 3. Produção (Prod)
- Entry point: `lib/main_prod.dart`
- URL da API: URL de produção configurada com HTTPS.
- Identificador visual: Banners de debug e badges de ambiente desativados.

---

## Requisitos de Ambiente

- Flutter SDK versão 3.13.7 ou superior.
- Dart SDK compatível.
- Android Studio ou Xcode configurados para emulação mobile (opcional, para testes em emulador).
- Google Chrome ou Edge (para execução na Web).

---

## Como Executar Localmente

### 1. Obter dependências
```bash
flutter pub get
```

### 2. Executar por ambiente

Executar em Desenvolvimento:
```bash
flutter run -t lib/main_dev.dart
```

Executar em Homologação (Staging):
```bash
flutter run -t lib/main_staging.dart
```

Executar em Produção:
```bash
flutter run -t lib/main_prod.dart
```

Também é possível definir o ambiente através de flag de compilação:
```bash
flutter run --dart-define=ENV=dev
```

### 3. Executar na Web
```bash
flutter run -d chrome -t lib/main_dev.dart
```

---

## Testes Automatizados e Análise Estática

Para garantir a estabilidade do código antes de cada alteração:

```bash
# Análise estática de regras de linting
flutter analyze

# Execução dos testes unitários e de widget
flutter test
```

---

## Integração com a API Backend

O aplicativo se comunica com a API ShapeFit através dos seguintes endpoints:

- POST /api/routines/prescribe: Solicita a prescrição científica de uma ficha de treino e inicializa o mesociclo correspondente.
- GET /api/routines/users/{userId}/active: Obtém os dias de treino e exercícios da ficha ativa do usuário.
- GET /api/routines/users/{userId}/mesocycle: Consulta o progresso atual do mesociclo ativo.
- POST /api/workouts: Envia o registro da sessão de treino concluída e incrementa o progresso do mesociclo.
- GET /api/workouts/users/{userId}/exercises/{exerciseId}/last-performance: Consulta as cargas e repetições do último treino realizado.
