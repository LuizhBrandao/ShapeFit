using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShapeFit.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddRoutineTemplatesAndMesocycles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "mesocycle_id",
                table: "workout_sessions",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "routine_day_id",
                table: "workout_sessions",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "routine_template_id",
                table: "workout_sessions",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "mesocycles",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    RoutineTemplateId = table.Column<Guid>(type: "uuid", nullable: false),
                    CycleNumber = table.Column<int>(type: "integer", nullable: false),
                    TargetSessionsCount = table.Column<int>(type: "integer", nullable: false),
                    CompletedSessionsCount = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    StartedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    FinishedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Goal = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_mesocycles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "routine_templates",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    Description = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    Division = table.Column<int>(type: "integer", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    IsAiGenerated = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_routine_templates", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "routine_days",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Order = table.Column<int>(type: "integer", nullable: false),
                    Description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    routine_template_id = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_routine_days", x => x.Id);
                    table.ForeignKey(
                        name: "FK_routine_days_routine_templates_routine_template_id",
                        column: x => x.routine_template_id,
                        principalTable: "routine_templates",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "routine_exercises",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ExerciseId = table.Column<Guid>(type: "uuid", nullable: false),
                    CustomExerciseName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    TargetMuscle = table.Column<int>(type: "integer", nullable: false),
                    Order = table.Column<int>(type: "integer", nullable: false),
                    TargetSets = table.Column<int>(type: "integer", nullable: false),
                    rep_range_min = table.Column<int>(type: "integer", nullable: false),
                    rep_range_max = table.Column<int>(type: "integer", nullable: false),
                    TargetRir = table.Column<int>(type: "integer", nullable: true),
                    RestIntervalSeconds = table.Column<int>(type: "integer", nullable: false),
                    Notes = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    routine_day_id = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_routine_exercises", x => x.Id);
                    table.ForeignKey(
                        name: "FK_routine_exercises_routine_days_routine_day_id",
                        column: x => x.routine_day_id,
                        principalTable: "routine_days",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_workout_sessions_mesocycle_id",
                table: "workout_sessions",
                column: "mesocycle_id");

            migrationBuilder.CreateIndex(
                name: "IX_workout_sessions_routine_template_id",
                table: "workout_sessions",
                column: "routine_template_id");

            migrationBuilder.CreateIndex(
                name: "IX_mesocycles_RoutineTemplateId",
                table: "mesocycles",
                column: "RoutineTemplateId");

            migrationBuilder.CreateIndex(
                name: "IX_mesocycles_UserId_Status",
                table: "mesocycles",
                columns: new[] { "UserId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_routine_days_routine_template_id",
                table: "routine_days",
                column: "routine_template_id");

            migrationBuilder.CreateIndex(
                name: "IX_routine_exercises_routine_day_id",
                table: "routine_exercises",
                column: "routine_day_id");

            migrationBuilder.CreateIndex(
                name: "IX_routine_templates_UserId_IsActive",
                table: "routine_templates",
                columns: new[] { "UserId", "IsActive" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "mesocycles");

            migrationBuilder.DropTable(
                name: "routine_exercises");

            migrationBuilder.DropTable(
                name: "routine_days");

            migrationBuilder.DropTable(
                name: "routine_templates");

            migrationBuilder.DropIndex(
                name: "IX_workout_sessions_mesocycle_id",
                table: "workout_sessions");

            migrationBuilder.DropIndex(
                name: "IX_workout_sessions_routine_template_id",
                table: "workout_sessions");

            migrationBuilder.DropColumn(
                name: "mesocycle_id",
                table: "workout_sessions");

            migrationBuilder.DropColumn(
                name: "routine_day_id",
                table: "workout_sessions");

            migrationBuilder.DropColumn(
                name: "routine_template_id",
                table: "workout_sessions");
        }
    }
}
