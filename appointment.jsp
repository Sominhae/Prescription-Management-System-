<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Appointments</title>
  <style>
    body {
      font-family: Arial;
      background: #f4f4f4;
      padding: 30px;
    }
    h2 {
      text-align: center;
      color: #2C3E50;
    }
    .message {
      text-align: center;
      padding: 10px;
      margin-bottom: 20px;
    }
    .success { background-color: #d4edda; color: #155724; }
    .error { background-color: #f8d7da; color: #721c24; }
    input[type="text"] {
      padding: 10px;
      border-radius: 5px;
      border: 1px solid #ccc;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      background: #fff;
      margin-top: 20px;
    }
    th, td {
      padding: 10px;
      border: 1px solid #ccc;
      text-align: center;
    }
    th {
      background-color: #2C3E50;
      color: white;
    }
    a {
      margin: 5px;
      padding: 5px 10px;
      border-radius: 5px;
      text-decoration: none;
      color: white;
      display: inline-block;
    }
    .delete-btn {
      background-color: #e74c3c;
    }
    .update-btn {
      background-color: #3498db;
    }
    .search-form {
      text-align: center;
      margin-bottom: 20px;
    }
    .search-form input {
      width: 300px;
    }
    .search-form button {
      background-color: #2C3E50;
      color: white;
      padding: 10px;
      border: none;
      border-radius: 5px;
    }
    form.inline {
      display: inline;
    }
  </style>
</head>
<body>

<%
  String appointment_id = request.getParameter("appointment_id");
  String doctor_id = request.getParameter("doctor_id");
  String patient_id = request.getParameter("patient_id");
  String appointment = request.getParameter("appointment");
  String purpose = request.getParameter("purpose");
  String status = request.getParameter("status");

  String search = request.getParameter("search");
  String action = request.getParameter("action");

  try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

    if ("delete".equals(action)) {
      int deleteId = Integer.parseInt(request.getParameter("id"));

      try {
        // Show details before deletion
        String selectQuery = "SELECT doctor_id, patient_id, TO_CHAR(appointment, 'YYYY-MM-DD HH24:MI') FROM appointment WHERE appointment_id = ?";
        PreparedStatement ps = con.prepareStatement(selectQuery);
        ps.setInt(1, deleteId);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
          out.println("<div class='message success'><strong>Details of Deleted Appointment:</strong><br>");
          out.println("Doctor ID: " + rs.getString(1) + "<br>");
          out.println("Patient ID: " + rs.getString(2) + "<br>");
          out.println("Date: " + rs.getString(3) + "<br>");

          // Check for related prescriptions
          PreparedStatement checkPs = con.prepareStatement("SELECT COUNT(*) FROM prescription WHERE appointment_id = ?");
          checkPs.setInt(1, deleteId);
          ResultSet checkRs = checkPs.executeQuery();
          checkRs.next();
          int count = checkRs.getInt(1);
          checkRs.close();
          checkPs.close();

          if (count > 0) {
            out.println("<span style='color:red;'>❌ Cannot delete: Related prescriptions exist.</span></div>");
          } else {
            // Delete
            String deleteQuery = "DELETE FROM appointment WHERE appointment_id = ?";
            ps = con.prepareStatement(deleteQuery);
            ps.setInt(1, deleteId);
            ps.executeUpdate();
            out.println("<br>✅ Appointment Deleted Successfully!</div>");
          }

        } else {
          out.println("<div class='message error'>No appointment found with ID: " + deleteId + "</div>");
        }

        rs.close();
        ps.close();
      } catch (Exception e) {
        out.println("<div class='message error'>Error: " + e.getMessage() + "</div>");
      }

    } else if ("update".equals(action)) {
      String updateQuery = "UPDATE appointment SET doctor_id=?, patient_id=?, appointment=TO_DATE(?, 'YYYY-MM-DD\"T\"HH24:MI'), purpose=?, status=? WHERE appointment_id=?";
      PreparedStatement ps = con.prepareStatement(updateQuery);
      ps.setInt(1, Integer.parseInt(doctor_id));
      ps.setInt(2, Integer.parseInt(patient_id));
      ps.setString(3, appointment);
      ps.setString(4, purpose);
      ps.setString(5, status);
      ps.setInt(6, Integer.parseInt(appointment_id));
      ps.executeUpdate();
      ps.close();
%>
      <div class="message success">✅ Appointment updated successfully!</div>
<%
    } else if (appointment_id != null && doctor_id != null && patient_id != null && appointment != null && action == null) {
      String insertQuery = "INSERT INTO appointment (appointment_id, doctor_id, patient_id, appointment, purpose, status) VALUES (?, ?, ?, TO_DATE(?, 'YYYY-MM-DD\"T\"HH24:MI'), ?, ?)";
      PreparedStatement ps = con.prepareStatement(insertQuery);
      ps.setInt(1, Integer.parseInt(appointment_id));
      ps.setInt(2, Integer.parseInt(doctor_id));
      ps.setInt(3, Integer.parseInt(patient_id));
      ps.setString(4, appointment);
      ps.setString(5, purpose);
      ps.setString(6, status);
      ps.executeUpdate();
      ps.close();
%>
      <div class="message success">✅ Appointment added successfully!</div>
<%
    }
%>

<h2>All Appointments</h2>

<div class="search-form">
  <form method="get">
    <input type="text" name="search" placeholder="Search by Patient ID, Doctor ID or Status" value="<%= (search != null ? search : "") %>"/>
    <button type="submit">Search</button>
  </form>
</div>

<table>
  <tr>
    <th>ID</th>
    <th>Doctor ID</th>
    <th>Patient ID</th>
    <th>Date</th>
    <th>Purpose</th>
    <th>Status</th>
    <th>Actions</th>
  </tr>

<%
    String query = "SELECT * FROM appointment";
    if (search != null && !search.trim().isEmpty()) {
      query += " WHERE LOWER(doctor_id || patient_id || status) LIKE ?";
    }
    query += " ORDER BY appointment_id";

    PreparedStatement stmt = con.prepareStatement(query);
    if (search != null && !search.trim().isEmpty()) {
      stmt.setString(1, "%" + search.toLowerCase() + "%");
    }

    ResultSet rs = stmt.executeQuery();

    while (rs.next()) {
      int id = rs.getInt("appointment_id");
      String docId = rs.getString("doctor_id");
      String patId = rs.getString("patient_id");
      String time = rs.getTimestamp("appointment").toLocalDateTime().toString().substring(0, 16);
      String purp = rs.getString("purpose");
      String stat = rs.getString("status");
%>
  <tr>
    <td><%= id %></td>
    <td><%= docId %></td>
    <td><%= patId %></td>
    <td><%= time %></td>
    <td><%= purp %></td>
    <td><%= stat %></td>
    <td>
      <a class="update-btn" href="edit_appointment.jsp?appointment_id=<%= id %>&doctor_id=<%= docId %>&patient_id=<%= patId %>&appointment=<%= time %>&purpose=<%= purp %>&status=<%= stat %>">Update</a>
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

<a href="appointment.html"> Add Another Appointment</a>

</body>
</html>
