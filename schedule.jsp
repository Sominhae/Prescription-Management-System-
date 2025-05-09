<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Schedule Management</title>
    <style>
        body { font-family: Arial; background-color: #f4f4f4; padding: 30px; }
        h2 { text-align: center; color: #2C3E50; }
        .message { text-align: center; padding: 10px; margin-bottom: 20px; }
        .success { background-color: #d4edda; color: #155724; }
        .error { background-color: #f8d7da; color: #721c24; }
        table { width: 100%; border-collapse: collapse; background-color: #fff; margin-top: 20px; }
        th, td { padding: 10px; border: 1px solid #ccc; text-align: center; }
        th { background-color: #2C3E50; color: white; }
        a { padding: 5px 10px; border-radius: 5px; text-decoration: none; color: white; }
        .update-btn { background-color: #3498db; }
        .delete-btn { background-color: #e74c3c; border: none; cursor: pointer; color: white; }
        form.inline { display: inline; }
        .search-form { text-align: center; margin-bottom: 20px; }
        input[type="text"], input[type="date"] { padding: 10px; width: 200px; }
        button { padding: 10px; background: #2C3E50; color: white; border: none; border-radius: 5px; }
    </style>
</head>
<body>

<%
    String dateStr = request.getParameter("schedule_date");
    String timeSlot = request.getParameter("time_slot");
    String patientId = request.getParameter("patient_id");
    String status = request.getParameter("status");
    String action = request.getParameter("action");
    String search = request.getParameter("search");

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

        if ("delete".equals(action)) {
            PreparedStatement delStmt = conn.prepareStatement("DELETE FROM schedule WHERE schedule_date=? AND time_slot=? AND patient_id=?");
            delStmt.setDate(1, java.sql.Date.valueOf(request.getParameter("d")));
            delStmt.setString(2, request.getParameter("t"));
            delStmt.setInt(3, Integer.parseInt(request.getParameter("p")));
            delStmt.executeUpdate();
%>
            <div class="message success">✅ Schedule deleted successfully.</div>
<%
            delStmt.close();
        } else if (dateStr != null && timeSlot != null && patientId != null && status != null && action == null) {
            String insertSQL = "INSERT INTO schedule (schedule_date, time_slot, patient_id, status) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(insertSQL);
            ps.setDate(1, java.sql.Date.valueOf(dateStr));
            ps.setString(2, timeSlot);
            ps.setInt(3, Integer.parseInt(patientId));
            ps.setString(4, status);
            ps.executeUpdate();
%>
            <div class="message success">✅ Schedule added successfully!</div>
<%
            ps.close();
        }
%>

<h2>Schedule List</h2>

<div class="search-form">
    <form method="get">
        <input type="text" name="search" placeholder="Search by Status or Time" value="<%= (search != null ? search : "") %>"/>
        <button type="submit">Search</button>
    </form>
</div>

<table>
    <tr>
        <th>Date</th>
        <th>Time Slot</th>
        <th>Patient ID</th>
        <th>Status</th>
        <th>Actions</th>
    </tr>

<%
        String query = "SELECT * FROM schedule";
        if (search != null && !search.trim().isEmpty()) {
            query += " WHERE LOWER(status || time_slot) LIKE ?";
        }
        query += " ORDER BY schedule_date";

        PreparedStatement stmt = conn.prepareStatement(query);
        if (search != null && !search.trim().isEmpty()) {
            stmt.setString(1, "%" + search.toLowerCase() + "%");
        }

        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            String schedDate = rs.getDate("schedule_date").toString();
            String slot = rs.getString("time_slot");
            int pid = rs.getInt("patient_id");
            String schedStatus = rs.getString("status");
%>
    <tr>
        <td><%= schedDate %></td>
        <td><%= slot %></td>
        <td><%= pid %></td>
        <td><%= schedStatus %></td>
        <td>
            <a class="update-btn" href="edit_schedule.jsp?schedule_date=<%= schedDate %>&time_slot=<%= slot %>&patient_id=<%= pid %>&status=<%= schedStatus %>">Update</a>
            <form method="post" class="inline">
                <input type="hidden" name="d" value="<%= schedDate %>">
                <input type="hidden" name="t" value="<%= slot %>">
                <input type="hidden" name="p" value="<%= pid %>">
                <input type="hidden" name="action" value="delete">
                <button type="submit" class="delete-btn">Delete</button>
            </form>
        </td>
    </tr>
<%
        }
        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
%>
    <div class="message error">Error: <%= e.getMessage() %></div>
<%
    }
%>
</table>

<a href="schedule.html">← Add New Schedule</a>

</body>
</html>
