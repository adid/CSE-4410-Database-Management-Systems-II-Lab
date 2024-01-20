#include <iostream>
#include <fstream>
#include <cstdlib>

int main() {
    // Open a file for writing
   std::ofstream outputFile("D:\\Study\\Semester 4, Summer 2024\\DBMS 2 LAB\\LAB 2\\data.sql");

    if (!outputFile.is_open()) {
        std::cerr << "Error opening file for writing\n";
        return 1;
    }

    for (int i = 1; i <= 10; ++i) {
        outputFile << "INSERT INTO Department (ID, Name) VALUES\n";
        outputFile << "  (" << i << ", 'Department" << i << "')";
        outputFile << (i < 10 ? ";\n" : ";\n\n");
    }

    for (int i = 1; i <= 5000; ++i) {
        outputFile << "\nINSERT INTO Student (ID, name, dept_ID) VALUES\n";
        outputFile << "  (" << i << ", 'Student" << i << "', " << std::rand() % 10 + 1 << ")";
        outputFile << (i < 5000 ? ";\n" : ";\n\n");
    }

    for (int i = 1; i <= 200; ++i) {
        outputFile << "\nINSERT INTO Course (course_code, name, credit, offered_by_dept_ID) VALUES\n";
        outputFile << "  ('C" << i << "', 'Course" << i << "', " << std::rand() % 5 + 1 << ", " << std::rand() % 10 + 1 << ")";
        outputFile << (i < 200 ? ";\n" : ";\n\n");
    }

    // Close the file
    outputFile.close();

    std::cout << "Data has been saved to file\n";

    return 0;
}
