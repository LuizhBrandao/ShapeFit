using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShapeFit.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "exercises",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    Description = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    PrimaryMuscle = table.Column<int>(type: "integer", nullable: false),
                    MediaUrl = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    IsCustom = table.Column<bool>(type: "boolean", nullable: false),
                    secondary_muscles = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_exercises", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "workout_sessions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    StartedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    FinishedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Notes = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    client_sync_id = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_workout_sessions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "workout_exercise_logs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ExerciseId = table.Column<Guid>(type: "uuid", nullable: false),
                    Order = table.Column<int>(type: "integer", nullable: false),
                    Notes = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    workout_session_id = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_workout_exercise_logs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_workout_exercise_logs_workout_sessions_workout_session_id",
                        column: x => x.workout_session_id,
                        principalTable: "workout_sessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "workout_set_logs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SetOrder = table.Column<int>(type: "integer", nullable: false),
                    Type = table.Column<int>(type: "integer", nullable: false),
                    weight_value = table.Column<decimal>(type: "numeric(8,2)", precision: 8, scale: 2, nullable: false),
                    weight_unit = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    Repetitions = table.Column<int>(type: "integer", nullable: false),
                    RepsInReserve = table.Column<int>(type: "integer", nullable: true),
                    IsCompleted = table.Column<bool>(type: "boolean", nullable: false),
                    CompletedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    workout_exercise_log_id = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_workout_set_logs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_workout_set_logs_workout_exercise_logs_workout_exercise_log~",
                        column: x => x.workout_exercise_log_id,
                        principalTable: "workout_exercise_logs",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_workout_exercise_logs_workout_session_id",
                table: "workout_exercise_logs",
                column: "workout_session_id");

            migrationBuilder.CreateIndex(
                name: "IX_workout_sessions_client_sync_id",
                table: "workout_sessions",
                column: "client_sync_id",
                unique: true,
                filter: "\"client_sync_id\" IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_workout_sessions_UserId_StartedAt",
                table: "workout_sessions",
                columns: new[] { "UserId", "StartedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_workout_set_logs_workout_exercise_log_id",
                table: "workout_set_logs",
                column: "workout_exercise_log_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "exercises");

            migrationBuilder.DropTable(
                name: "workout_set_logs");

            migrationBuilder.DropTable(
                name: "workout_exercise_logs");

            migrationBuilder.DropTable(
                name: "workout_sessions");
        }
    }
}
