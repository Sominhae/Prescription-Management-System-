<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Edit Doctor</title>
  <style>
    body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 40px; }
    h2 { text-align: center; color: #2C3E50; }
    form { max-width: 500px; margin: auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    label { display: block; margin-top: 15px; }
    input[type="text"], input[type="number"] {
      width: 100%; padding: 10px; margin-top: 5px; border: 1px solid #ccc; border-radius: 5px;
    }
    button {
      margin-top: 20px; padding: 10px 20px;
      background-color: #2C3E50; color: white;
      border: none; border-radius: 5px; cursor: pointer;
    }
    .message { text-align: center; margin: 20px auto; padding: 10px; width: 400px; }
    .success { background-color: #d4edda; color: #155724; }
    .error { background-color: #f8d7da; color: #721c24; }
    a { display: block; text-align: center; margin-top: 20px; color: #2C3E50; text-decoration: none; }
  </style>
</head>
<body>

<%
  String doctorId = request.getParameter("doctor_id");
  String name = request.getParameter("name");
  String specialization = request.getParameter("specialization");
  String contactno = request.getParameter("contactno");
  String clinic = request.getParameter("clinic");

  String method = request.getMethod();

  if ("POST".equalsIgnoreCase(method)) {
    // Update logic
    String newName = request.getParameter("name");
    String newSpecialization = request.getParameter("specialization");
    String newContactno = request.getParameter("contactno");
    String newClinic = request.getParameter("clinic");

    try {
      Class.forName("oracle.jdbc.driver.OracleDriver");
      Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

      PreparedStatement ps = con.prepareStatement("UPDATE doctor SET name = ?, specialization = ?, contactno = ?, clinic = ? WHERE doctor_id = ?");
      ps.setString(1, newName);
      ps.setString(2, newSpecialization);
      ps.setString(3, newContactno);
      ps.setString(4, newClinic);
      ps.setInt(5, Integer.parseInt(doctorId));

      int updated = ps.executeUpdate();
      ps.close();
      con.close();

      if (updated > 0) {
%>
  <div class="message success">✅ Doctor updated successfully!</div>
<%
      } else {
%>
  <div class="message error">❌ Doctor not found or update failed.</div>
<%
      }
    } catch (Exception e) {
%>
  <div class="message error">Error: <%= e.getMessage() %></div>
<%
    }
  }
%>

<h2>Edit Doctor</h2>
<form method="post" action="edit_doctor.jsp">
  <label for="doctor_id">Doctor ID (readonly)</label>
  <input type="text" name="doctor_id" value="<%= doctorId %>" readonly>

  <label for="name">Name</label>
  <input type="text" name="name" value="<%= name %>" required>

  <label for="specialization">Specialization</label>
  <input type="text" name="specialization" value="<%= specialization %>" required>

  <label for="contactno">Contact No</label>
  <input type="text" name="contactno" value="<%= contactno %>" required>

  <label for="clinic">Clinic</label>
  <input type="text" name="clinic" value="<%= clinic %>" required>

  <button type="submit">Update Doctor</button>
</form>

<a href="doctor.jsp">← Back to Doctors List</a>

</body>
</html>
