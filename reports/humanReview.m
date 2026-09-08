function review = humanReview(aiResult)

disp("======================================");
disp("          HUMAN REVIEW");
disp("======================================");

fprintf( ...
    "AI Result: %s\n", ...
    aiResult.gradeName);

fprintf( ...
    "AI Score: %.4f\n", ...
    aiResult.score);

disp("");

disp("1 = Accept AI result");
disp("2 = Override AI result");

choice = input("Enter choice: ");

if choice == 1

    review.finalGrade = aiResult.grade;

    review.finalGradeName = ...
        aiResult.gradeName;

    review.action = "ACCEPTED";

elseif choice == 2

    grade = input( ...
        "Enter final DR grade (0-4): ");

    review.finalGrade = grade;

    drNames = [
        "No DR"
        "Mild DR"
        "Moderate DR"
        "Severe DR"
        "Proliferative DR"
        ];

    review.finalGradeName = ...
        drNames(grade+1);

    review.action = "OVERRIDDEN";

else

    error("Invalid choice.");

end

review.notes = input( ...
    "Enter reviewer notes: ", ...
    "s");

end