<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Edit Schedule</title>
  <style>
    body { font-family: Arial; background-color: #f4f4f4; padding: 30px; }
    h2 { text-align: center; color: #2C3E50; }
    form { max-width: 500px; margin: auto; background: #fff; padding: 20px; border-radius: 10px; }
    label { display: block; margin-top: 10px; }
    input, select { width: 100%; padding: 10px; margin-top: 5px; }
    button { margin-top: 20px; padding: 10px; background: #2C3E50; color: white; border: none; width: 100%; border-radius: 5px; }
    .success { text-align: center; color: green; }
    .error { text-align: center; color: red; }
    a { display: block; text-align: center; margin-top: 20px; color: #2C3E50; text-decoration: none; }
  </style>
</head>
<body>

<%
String schedule_date = request.getParameter("schedule_date");
String time_slot = request.getParameter("time_slot");
String patient_id = request.getParameter("patient_id");
String status = request.getParameter("status");
String newStatus = request.getParameter("new_status");

try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

    if (newStatus != null) {
        PreparedStatement ps = conn.prepareStatement(
            "UPDATE schedule SET status = ? WHERE schedule_date = ? AND time_slot = ? AND patient_id = ?"
        );
        ps.setString(1, newStatus);
        ps.setDate(2, java.sql.Date.valueOf(schedule_date));
        ps.setString(3, time_slot);
        ps.setInt(4, Integer.parseInt(patient_id));
        int rowsUpdated = ps.executeUpdate();
        ps.close();

        if (rowsUpdated > 0) {
%>
            <p class="success">✅ Schedule updated successfully.</p>
<%
        } else {
%>
            <p class="error">❌ Failed to update schedule.</p>
<%
        }
        conn.close();
    }
} catch (Exception e) {
%>
    <p class="error">Error: <%= e.getMessage() %></p>
<%
}
%>

<h2>Edit Schedule</h2>
<form method="post">
    <label>Schedule Date:</label>
    <input type="date" name="schedule_date" value="<%= schedule_date %>" readonly>

    <label>Time Slot:</label>
    <input type="text" name="time_slot" value="<%= time_slot %>" readonly>

    <label>Patient ID:</label>
    <input type="text" name="patient_id" value="<%= patient_id %>" readonly>

    <label>Status:</label>
    <input type="text" name="new_status" value="<%= status %>">

    <button type="submit">Update Schedule</button>
</form>

<a href="schedule.jsp">← Back to Schedule List</a>
</body>
</html>
