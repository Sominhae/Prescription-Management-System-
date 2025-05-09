<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Patients</title>
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
  String patientId = request.getParameter("patient_id");
  String name = request.getParameter("name");
  String dob = request.getParameter("dob");
  String gender = request.getParameter("gender");
  String address = request.getParameter("address");
  String contactno = request.getParameter("contactno");
  String search = request.getParameter("search");
  String action = request.getParameter("action");

  try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

    if ("delete".equals(action)) {
      int idToDelete = Integer.parseInt(request.getParameter("id"));
      PreparedStatement ps = con.prepareStatement("DELETE FROM patient WHERE patient_id = ?");
      ps.setInt(1, idToDelete);
      int deleted = ps.executeUpdate();
      if (deleted > 0) {
%>
  <div class="message success">✅ Patient with ID <%= idToDelete %> deleted successfully.</div>
<%
      } else {
%>
  <div class="message error">❌ Patient not found.</div>
<%
      }
      ps.close();
    } else if (patientId != null && name != null && dob != null && gender != null && address != null && contactno != null && action == null) {
      String query = "INSERT INTO patient (patient_id, name, dob, gender, address, contactno) VALUES (?, ?, ?, ?, ?, ?)";
      PreparedStatement ps = con.prepareStatement(query);
      ps.setInt(1, Integer.parseInt(patientId));
      ps.setString(2, name);
      ps.setDate(3, Date.valueOf(dob));
      ps.setString(4, gender);
      ps.setString(5, address);
      ps.setString(6, contactno);
      ps.executeUpdate();
      ps.close();
%>
  <div class="message success">✅ Patient added successfully!</div>
<%
    }

%>

<h2>All Patients</h2>

<div class="search-form">
  <form method="get">
    <input type="text" name="search" placeholder="Search by Name or Address" value="<%= (search != null ? search : "") %>"/>
    <button type="submit">Search</button>
  </form>
</div>

<table>
  <tr>
    <th>Patient ID</th>
    <th>Name</th>
    <th>DOB</th>
    <th>Gender</th>
    <th>Address</th>
    <th>Contact No</th>
    <th>Actions</th>
  </tr>

<%
    String query = "SELECT * FROM patient";
    if (search != null && !search.trim().isEmpty()) {
      query += " WHERE LOWER(name || address) LIKE ?";
    }
    query += " ORDER BY patient_id";

    PreparedStatement stmt = con.prepareStatement(query);
    if (search != null && !search.trim().isEmpty()) {
      stmt.setString(1, "%" + search.toLowerCase() + "%");
    }

    ResultSet rs = stmt.executeQuery();
    while (rs.next()) {
      int id = rs.getInt("patient_id");
      String pname = rs.getString("name");
      Date pdob = rs.getDate("dob");
      String pgender = rs.getString("gender");
      String paddress = rs.getString("address");
      String pcontact = rs.getString("contactno");
%>
  <tr>
    <td><%= id %></td>
    <td><%= pname %></td>
    <td><%= pdob %></td>
    <td><%= pgender %></td>
    <td><%= paddress %></td>
    <td><%= pcontact %></td>
    <td>
      <a class="update-btn" href="edit_patient.jsp?patient_id=<%= id %>&name=<%= pname %>&dob=<%= pdob %>&gender=<%= pgender %>&address=<%= paddress %>&contactno=<%= pcontact %>">Update</a>
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
  <a href="patient.html">Add Another Patient</a>
  <a href="checkup.html">Your Regular Checkup Details</a>
  <a href="medical_history.jsp">See Medical History</a>
</div>

</body>
</html>
