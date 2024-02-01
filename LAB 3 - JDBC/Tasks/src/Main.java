import java.sql.*;
import java.util.Scanner;

class Main {
    public static void main(String args[]) {
        try {
            // step1 load the driver class
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // step2 create the connection object
            Connection con = DriverManager.getConnection(
                    "jdbc:oracle:thin:@localhost:1521:xe", "c_210042172", "cse4308");

            // step3 create the statement object
            Statement stmt = con.createStatement();

            //*****Task 1*****

            System.out.println("Selecting records from the table...");
            String QUERY = "SELECT COUNT(*) as altered_dept FROM department WHERE budget <= 99999";
            ResultSet rs = stmt.executeQuery(QUERY);

            int alteredDeptCount = 0;

            while (rs.next()) {
                alteredDeptCount = rs.getInt("altered_dept");
                System.out.println("Department No: " + alteredDeptCount);
            }
            rs.close();

            if (alteredDeptCount > 0) {
                System.out.println("Decreasing Budget");
                String sql1 = "UPDATE department SET budget = budget * 0.9 WHERE budget > 99999";
                stmt.executeUpdate(sql1);
            } else {
                System.out.println("No departments with budget > 99999 found.");
            }

            //*****Task 2*****

            Scanner scanner = new Scanner(System.in);
            System.out.print("Enter the day of the week (e.g., Monday): ");
            String dayOfWeek = scanner.nextLine();
            System.out.print("Enter the starting hour (24-hour format, e.g., 13): ");
            int startHour = scanner.nextInt();
            System.out.print("Enter the ending hour (24-hour format, e.g., 16): ");
            int endHour = scanner.nextInt();

            String sql = "SELECT DISTINCT i.name " +
                    "FROM instructor i " +
                    "JOIN teaches t ON i.ID = t.ID " +
                    "JOIN section s ON t.course_id = s.course_id " +
                    "JOIN time_slot ts ON s.time_slot_id = ts.time_slot_id " +
                    "WHERE ts.day = ? AND ts.start_hr <= ? AND ts.end_hr >= ?";

            PreparedStatement preparedStatement = con.prepareStatement(sql);
            preparedStatement.setString(1, dayOfWeek);
            preparedStatement.setInt(2, startHour);
            preparedStatement.setInt(3, endHour);

            ResultSet resultSet = preparedStatement.executeQuery();

            // Print the names of instructors
            System.out.println("Instructors taking classes during " +
                    dayOfWeek + " from " + startHour + " to " + endHour + ":");
            while (resultSet.next()) {
                System.out.println(resultSet.getString("name"));
            }

            //*****Task 3*****

            // Take N as input from the user
            System.out.print("Enter the value of N: ");
            int N = scanner.nextInt();

            String topStudentsQuery = "SELECT * FROM (" +
                    "    SELECT s.ID, s.name, s.dept_name, COUNT(t.course_id) AS num_courses " +
                    "    FROM student s " +
                    "    LEFT JOIN takes t ON s.ID = t.ID " +
                    "    GROUP BY s.ID, s.name, s.dept_name " +
                    "    ORDER BY num_courses DESC" +
                    ") WHERE ROWNUM <= ?";

            PreparedStatement topStudentsStmt = con.prepareStatement(topStudentsQuery);
            topStudentsStmt.setInt(1, N);
            ResultSet topStudentsResultSet = topStudentsStmt.executeQuery();

            System.out.println("Top " + N + " students based on the number of courses taken:");
            System.out.printf("%-10s %-20s %-20s %-15s%n", "ID", "Name", "Department Name", "Courses Taken");
            System.out.println("-----------------------------------------------------");

            while (topStudentsResultSet.next()) {
                String studentID = topStudentsResultSet.getString("ID");
                String studentName = topStudentsResultSet.getString("name");
                String deptName = topStudentsResultSet.getString("dept_name");
                int numCourses = topStudentsResultSet.getInt("num_courses");

                System.out.printf("%-10s %-20s %-20s %-15s%n", studentID, studentName, deptName, numCourses);
            }

            // *****Task 4*****

            String lowestDeptQuery = "SELECT dept_name\n" +
                    "FROM (\n" +
                    "    SELECT dept_name, COUNT(*) AS student_count\n" +
                    "    FROM student\n" +
                    "    GROUP BY dept_name\n" +
                    "    ORDER BY student_count ASC\n" +
                    ")\n" +
                    "WHERE ROWNUM = 1";

            PreparedStatement lowestDeptStmt = con.prepareStatement(lowestDeptQuery);
            ResultSet lowestDeptResultSet = lowestDeptStmt.executeQuery();

            String lowestDeptName = null;
            if (lowestDeptResultSet.next()) {
                lowestDeptName = lowestDeptResultSet.getString("dept_name");
            }

            String maxStudentIDQuery = "SELECT MAX(TO_NUMBER(ID)) AS max_id FROM student";
            PreparedStatement maxStudentIDStmt = con.prepareStatement(maxStudentIDQuery);
            ResultSet maxStudentIDResultSet = maxStudentIDStmt.executeQuery();

            int newStudentID = 0;
            if (maxStudentIDResultSet.next()) {
                newStudentID = maxStudentIDResultSet.getInt("max_id") + 1;
            }

            String insertNewStudentQuery = "INSERT INTO student(ID, name, dept_name, tot_cred) VALUES (?, 'Jane Doe', ?, 0)";
            PreparedStatement insertNewStudentStmt = con.prepareStatement(insertNewStudentQuery);
            insertNewStudentStmt.setInt(1, newStudentID);
            insertNewStudentStmt.setString(2, lowestDeptName);
            insertNewStudentStmt.executeUpdate();

            System.out.println("New student 'Jane Doe' with ID " + newStudentID +
                    " has been inserted into the department '" + lowestDeptName + "'.");

            // Task 5

            String studentsWithoutAdvisorQuery = "SELECT s.ID, s.name, s.dept_name\n" +
                    "FROM student s\n" +
                    "WHERE s.ID NOT IN (\n" +
                    "    SELECT a.s_ID\n" +
                    "    FROM advisor a\n" +
                    ")";

            PreparedStatement studentsWithoutAdvisorStmt = con.prepareStatement(studentsWithoutAdvisorQuery);
            ResultSet studentsWithoutAdvisorResultSet = studentsWithoutAdvisorStmt.executeQuery();

            while (studentsWithoutAdvisorResultSet.next()) {
                String studentID = studentsWithoutAdvisorResultSet.getString("ID");
                String studentName = studentsWithoutAdvisorResultSet.getString("name");
                String deptName = studentsWithoutAdvisorResultSet.getString("dept_name");

                String leastAdvisedAdvisorQuery = "SELECT * FROM (" +
                        "    SELECT i.ID AS i_ID, i.name, COUNT(a.s_ID) AS num_students_advised " +
                        "    FROM instructor i " +
                        "    JOIN advisor a ON a.i_ID = i.ID " +
                        "    WHERE i.dept_name = ? " +
                        "    GROUP BY i.ID, i.name " +
                        "    ORDER BY num_students_advised ASC" +
                        ") WHERE ROWNUM = 1";

                PreparedStatement leastAdvisedAdvisorStmt = con.prepareStatement(leastAdvisedAdvisorQuery);
                leastAdvisedAdvisorStmt.setString(1, deptName);  // Set the department name
                ResultSet leastAdvisedAdvisorResultSet = leastAdvisedAdvisorStmt.executeQuery();

                String advisorID = null;
                String advisorName = null;
                int numStudentsAdvised = 0;

                if (leastAdvisedAdvisorResultSet.next()) {
                    advisorID = leastAdvisedAdvisorResultSet.getString("i_ID");
                    advisorName = leastAdvisedAdvisorResultSet.getString("name");
                    numStudentsAdvised = leastAdvisedAdvisorResultSet.getInt("num_students_advised");

                    String assignAdvisorQuery = "INSERT INTO advisor(s_ID, i_ID) VALUES (?, ?)";
                    PreparedStatement assignAdvisorStmt = con.prepareStatement(assignAdvisorQuery);
                    assignAdvisorStmt.setString(1, studentID);
                    assignAdvisorStmt.setString(2, advisorID);
                    assignAdvisorStmt.executeUpdate();
                }

                System.out.println("Student ID: " + studentID +
                        ", Student Name: " + studentName +
                        ", Department: " + deptName +
                        ", Advisor ID: " + (advisorID != null ? advisorID : "N/A") +
                        ", Advisor Name: " + (advisorName != null ? advisorName : "N/A") +
                        ", Number of Students Advised by Advisor: " + numStudentsAdvised);
            }

            // step5 close the connection object
            con.close();
        }

        catch (Exception e) {
            System.out.println(e);
        }
    }
}
