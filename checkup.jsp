<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Health Checkup Records</title>
  <style>
    body { font-family: Arial; background: #f4f4f4; padding: 30px; }
    h2 { text-align: center; color: #2C3E50; }
    .message { text-align: center; padding: 10px; margin-bottom: 20px; }
    .success { background-color: #d4edda; color: #155724; }
    .error { background-color: #f8d7da; color: #721c24; }
    input[type="text"] { padding: 10px; width: 300px; }
    button { padding: 10px; background: #2C3E50; color: white; border: none; border-radius: 5px; }
    table { width: 100%; border-collapse: collapse; background: #fff; margin-top: 20px; }
    th, td { padding: 10px; border: 1px solid #ccc; text-align: center; }
    th { background-color: #2C3E50; color: white; }
    a { padding: 5px 10px; border-radius: 5px; text-decoration: none; color: white; }
    .update-btn { background-color: #3498db; }
    .delete-btn { background-color: #e74c3c; }
    form.inline { display: inline; }
    .search-form { text-align: center; margin-bottom: 20px; }
  </style>
</head>
<body>

<%
  String checkup_id = request.getParameter("checkup_id");
  String patient_id = request.getParameter("patient_id");
  String types_of_checkup = request.getParameter("types_of_checkup");
  String results = request.getParameter("results");
  String search = request.getParameter("search");
  String action = request.getParameter("action");

  try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

    if ("delete".equals(action)) {
      int idToDelete = Integer.parseInt(request.getParameter("id"));
      PreparedStatement ps = con.prepareStatement("DELETE FROM health_checkup WHERE checkup_id = ?");
      ps.setInt(1, idToDelete);
      int deleted = ps.executeUpdate();
      if (deleted > 0) {
%>
  <div class="message success">✅ Record with Checkup ID <%= idToDelete %> deleted successfully.</div>
<%
      } else {
%>
  <div class="message error">❌ No record found to delete.</div>
<%
      }
      ps.close();
    } else if (checkup_id != null && patient_id != null && results != null && action == null) {
      PreparedStatement ps = con.prepareStatement("INSERT INTO health_checkup (checkup_id, patient_id, types_of_checkup, results) VALUES (?, ?, ?, ?)");
      ps.setInt(1, Integer.parseInt(checkup_id));
      ps.setInt(2, Integer.parseInt(patient_id));
      ps.setString(3, types_of_checkup);
      ps.setString(4, results);
      ps.executeUpdate();
      ps.close();
%>
  <div class="message success">✅ Health checkup added successfully!</div>
<%
    }
%>

<h2>Health Checkup Records</h2>

<div class="search-form">
  <form method="get">
    <input type="text" name="search" placeholder="Search by Patient ID or Type" value="<%= (search != null ? search : "") %>"/>
    <button type="submit">Search</button>
  </form>
</div>

<table>
  <tr>
    <th>Checkup ID</th>
    <th>Patient ID</th>
    <th>Type of Checkup</th>
    <th>Results</th>
    <th>Actions</th>
  </tr>

<%
    String query = "SELECT * FROM health_checkup";
    if (search != null && !search.trim().isEmpty()) {
      query += " WHERE LOWER(patient_id || types_of_checkup) LIKE ?";
    }
    query += " ORDER BY checkup_id";

    PreparedStatement stmt = con.prepareStatement(query);
    if (search != null && !search.trim().isEmpty()) {
      stmt.setString(1, "%" + search.toLowerCase() + "%");
    }

    ResultSet rs = stmt.executeQuery();
    while (rs.next()) {
      int id = rs.getInt("checkup_id");
      String pid = rs.getString("patient_id");
      String type = rs.getString("types_of_checkup");
      String res = rs.getString("results");
%>
  <tr>
    <td><%= id %></td>
    <td><%= pid %></td>
    <td><%= type %></td>
    <td><%= res %></td>
    <td>
      <a class="update-btn" href="edit_checkup.jsp?checkup_id=<%= id %>&patient_id=<%= pid %>&types_of_checkup=<%= type %>&results=<%= res %>">Update</a>
      <form method="post" class="inline">
        <input type="hidden" name="id" value="<%= id %>"/>
        <input type="hidden" name="action" value="delete"/>
        <button type="submit" class="delete-btn">Delete</button>
      </form>
    </td>
  </tr>
<%
    }
    rs.close();
    stmt.close();
    con.close();
  } catch (Exception e) {
%>
  <div class="message error">Error: <%= e.getMessage() %></div>
<%
  }
%>
</table>

<a href="appointment.html">Book an Appointment Today</a>

</body>
</html>
