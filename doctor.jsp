<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Doctors</title>
  <style>
    body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 30px; }
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
    input[type="text"] { padding: 10px; width: 300px; }
    button { padding: 10px; background: #2C3E50; color: white; border: none; border-radius: 5px; }
    .nav-links { text-align: center; margin-top: 30px; }
    .nav-links a { display: inline-block; margin: 5px 10px; color: #2C3E50; text-decoration: none; font-weight: bold; }
  </style>
</head>
<body>
<%
  String doctorId = request.getParameter("doctor_id");
  String name = request.getParameter("name");
  String specialization = request.getParameter("specialization");
  String contactno = request.getParameter("contactno");
  String clinic = request.getParameter("clinic");
  String search = request.getParameter("search");
  String action = request.getParameter("action");

  try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

    if ("delete".equals(action)) {
      int idToDelete = Integer.parseInt(request.getParameter("id"));
      PreparedStatement ps = con.prepareStatement("DELETE FROM doctor WHERE doctor_id = ?");
      ps.setInt(1, idToDelete);
      int deleted = ps.executeUpdate();
      ps.close();
%>
  <div class="message <%= (deleted > 0 ? "success" : "error") %>">
    <%= (deleted > 0 ? "✅ Doctor with ID " + idToDelete + " deleted successfully." : "❌ Doctor not found.") %>
  </div>
<%
    } else if (doctorId != null && name != null && specialization != null && contactno != null && clinic != null && action == null) {
      String query = "INSERT INTO doctor (doctor_id, name, specialization, contactno, clinic) VALUES (?, ?, ?, ?, ?)";
      PreparedStatement ps = con.prepareStatement(query);
      ps.setInt(1, Integer.parseInt(doctorId));
      ps.setString(2, name);
      ps.setString(3, specialization);
      ps.setString(4, contactno);
      ps.setString(5, clinic);
      ps.executeUpdate();
      ps.close();
%>
  <div class="message success">✅ Doctor added successfully!</div>
<%
    }
%>

<h2>All Doctors</h2>
<div class="search-form">
  <form method="get">
    <input type="text" name="search" placeholder="Search by Name or Specialization" value="<%= (search != null ? search : "") %>"/>
    <button type="submit">Search</button>
  </form>
</div>

<table>
  <tr>
    <th>Doctor ID</th>
    <th>Name</th>
    <th>Specialization</th>
    <th>Contact No</th>
    <th>Clinic</th>
    <th>Actions</th>
  </tr>
<%
    String query = "SELECT * FROM doctor";
    if (search != null && !search.trim().isEmpty()) {
      query += " WHERE LOWER(name || specialization) LIKE ?";
    }
    query += " ORDER BY doctor_id";

    PreparedStatement stmt = con.prepareStatement(query);
    if (search != null && !search.trim().isEmpty()) {
      stmt.setString(1, "%" + search.toLowerCase() + "%");
    }
    ResultSet rs = stmt.executeQuery();
    while (rs.next()) {
      int id = rs.getInt("doctor_id");
      String dname = rs.getString("name");
      String dspec = rs.getString("specialization");
      String dcontact = rs.getString("contactno");
      String dclinic = rs.getString("clinic");
%>
  <tr>
    <td><%= id %></td>
    <td><%= dname %></td>
    <td><%= dspec %></td>
    <td><%= dcontact %></td>
    <td><%= dclinic %></td>
    <td>
      <a class="update-btn" href="edit_doctor.jsp?doctor_id=<%= id %>&name=<%= dname %>&specialization=<%= dspec %>&contactno=<%= dcontact %>&clinic=<%= dclinic %>">Update</a>
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

<div class="nav-links">
  <a href="doctor.html">Add Another Doctor</a>
  <a href="schedule.html">Add your Schedule</a>
  <a href="medicine.jsp">Add Medicines</a>
  <a href="medical_history.jsp">See Medical History of Patients</a>
</div>

</body>
</html>