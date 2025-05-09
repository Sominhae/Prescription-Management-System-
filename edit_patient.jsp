<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Edit Patient</title>
  <style>
    body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 30px; }
    form { max-width: 600px; margin: auto; background: #fff; padding: 20px; border-radius: 10px; }
    label { display: block; margin-top: 10px; font-weight: bold; }
    input, textarea { width: 100%; padding: 8px; margin-top: 5px; }
    button { margin-top: 20px; padding: 10px 15px; background: #2C3E50; color: white; border: none; border-radius: 5px; }
    .message { text-align: center; padding: 10px; margin-bottom: 20px; }
    .success { background-color: #d4edda; color: #155724; }
    .error { background-color: #f8d7da; color: #721c24; }
    a { display: block; text-align: center; margin-top: 20px; color: #2C3E50; text-decoration: none; }
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
  String updated = request.getParameter("updated");

  if ("true".equals(updated)) {
%>
  <div class="message success">✅ Patient updated successfully!</div>
<%
  }

  if (request.getMethod().equals("POST")) {
    try {
      String newId = request.getParameter("patient_id");
      String newName = request.getParameter("name");
      String newDob = request.getParameter("dob");
      String newGender = request.getParameter("gender");
      String newAddress = request.getParameter("address");
      String newContactno = request.getParameter("contactno");

      Class.forName("oracle.jdbc.driver.OracleDriver");
      Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

      String updateQuery = "UPDATE patient SET name=?, dob=?, gender=?, address=?, contactno=? WHERE patient_id=?";
      PreparedStatement pstmt = conn.prepareStatement(updateQuery);
      pstmt.setString(1, newName);
      pstmt.setDate(2, Date.valueOf(newDob));
      pstmt.setString(3, newGender);
      pstmt.setString(4, newAddress);
      pstmt.setString(5, newContactno);
      pstmt.setInt(6, Integer.parseInt(newId));

      int result = pstmt.executeUpdate();
      pstmt.close();
      conn.close();

      if (result > 0) {
        response.sendRedirect("edit_patient.jsp?patient_id=" + newId + "&name=" + newName + "&dob=" + newDob + "&gender=" + newGender + "&address=" + newAddress + "&contactno=" + newContactno + "&updated=true");
        return;
      }
    } catch (Exception e) {
%>
  <div class="message error">❌ Error: <%= e.getMessage() %></div>
<%
    }
  }
%>

<h2 style="text-align:center;">Edit Patient</h2>

<form method="post" action="edit_patient.jsp">
  <label>ID (readonly)</label>
  <input type="text" value="<%= patientId %>" readonly />
  <input type="hidden" name="patient_id" value="<%= patientId %>" />

  <label>Name</label>
  <input type="text" name="name" value="<%= name %>" required />

  <label>DOB</label>
  <input type="date" name="dob" value="<%= dob %>" required />

  <label>Gender</label>
  <input type="text" name="gender" value="<%= gender %>" required />

  <label>Address</label>
  <textarea name="address" required><%= address %></textarea>

  <label>Contact No</label>
  <input type="text" name="contactno" value="<%= contactno %>" required />

  <button type="submit">Update Patient</button>
</form>

<a href="patient.jsp">⬅ Back to Patient List</a>

</body>
</html>
