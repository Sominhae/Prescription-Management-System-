<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Prescriptions</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #f5f5f5;
      padding: 40px;
      text-align: center;
    }
    .message {
      background-color: #fff;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 0 10px #ccc;
      max-width: 500px;
      margin: 0 auto;
    }
    .success {
      color: green;
    }
    .error {
      color: red;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      background-color: #fff;
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
      text-decoration: none;
      color: #2C3E50;
      font-weight: bold;
    }
    .delete-btn {
      background-color: #e74c3c;
      color: white;
      border: none;
      cursor: pointer;
      padding: 5px 10px;
    }
    .update-btn {
      background-color: #3498db;
      color: white;
      padding: 5px 10px;
      text-decoration: none;
      font-weight: bold;
    }
    .search-form {
      text-align: center;
      margin-bottom: 20px;
    }
    input[type="text"] {
      padding: 10px;
      width: 300px;
    }
    button {
      padding: 10px;
      background: #2C3E50;
      color: white;
      border: none;
      border-radius: 5px;
    }
  </style>
</head>
<body>

<%
  String search = request.getParameter("search");
  String action = request.getParameter("action");
  String prescriptionId = request.getParameter("prescription_id");
  String updatePrescriptionId = request.getParameter("update_prescription_id");
  String appointmentId = request.getParameter("appointment_id");
  String patientId = request.getParameter("patient_id");
  String doctorId = request.getParameter("doctor_id");
  String prescriptionDate = request.getParameter("prescription_date");
  String medicineId = request.getParameter("medicine_id");
  String notes = request.getParameter("notes");

  Connection conn = null;
  PreparedStatement pstmt = null;
  ResultSet rs = null;

  try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

    // Delete operation
    if ("delete".equals(action)) {
      int idToDelete = Integer.parseInt(request.getParameter("id"));
      String deleteQuery = "DELETE FROM prescription WHERE prescription_id = ?";
      pstmt = conn.prepareStatement(deleteQuery);
      pstmt.setInt(1, idToDelete);
      int deleted = pstmt.executeUpdate();
      if (deleted > 0) {
%>
  <div class="message success">✅ Prescription with ID <%= idToDelete %> deleted successfully.</div>
<%
      } else {
%>
  <div class="message error">❌ Prescription not found.</div>
<%
      }
    }

    // Update operation
    else if (updatePrescriptionId != null) {
      String updateQuery = "UPDATE prescription SET appointment_id = ?, patient_id = ?, doctor_id = ?, prescription_date = TO_DATE(?, 'YYYY-MM-DD'), medicine_id = ?, notes = ? WHERE prescription_id = ?";
      pstmt = conn.prepareStatement(updateQuery);
      pstmt.setInt(1, Integer.parseInt(appointmentId));
      pstmt.setInt(2, Integer.parseInt(patientId));
      pstmt.setInt(3, Integer.parseInt(doctorId));
      pstmt.setString(4, prescriptionDate);
      pstmt.setInt(5, Integer.parseInt(medicineId));
      pstmt.setString(6, notes);
      pstmt.setInt(7, Integer.parseInt(updatePrescriptionId));
      int updated = pstmt.executeUpdate();
      if (updated > 0) {
%>
  <div class="message success">✅ Prescription updated successfully!</div>
<%
      } else {
%>
  <div class="message error">❌ Failed to update prescription.</div>
<%
      }
    }

    // Insert operation (if prescription details are available)
    else if (prescriptionId != null && appointmentId != null && patientId != null && doctorId != null && prescriptionDate != null && medicineId != null && notes != null) {
      String insertQuery = "INSERT INTO prescription (prescription_id, appointment_id, patient_id, doctor_id, prescription_date, medicine_id, notes) " +
                           "VALUES (?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?)";
      pstmt = conn.prepareStatement(insertQuery);
      pstmt.setInt(1, Integer.parseInt(prescriptionId));
      pstmt.setInt(2, Integer.parseInt(appointmentId));
      pstmt.setInt(3, Integer.parseInt(patientId));
      pstmt.setInt(4, Integer.parseInt(doctorId));
      pstmt.setString(5, prescriptionDate);
      pstmt.setInt(6, Integer.parseInt(medicineId));
      pstmt.setString(7, notes);
      int result = pstmt.executeUpdate();
      if (result > 0) {
%>
  <div class="message success">✅ Prescription saved successfully!</div>
<%
      } else {
%>
  <div class="message error">❌ Failed to save prescription.</div>
<%
      }
    }

    // Search operation
    String query = "SELECT * FROM prescription";
    if (search != null && !search.trim().isEmpty()) {
      query += " WHERE LOWER(patient_id || doctor_id || prescription_id) LIKE ?";
    }
    query += " ORDER BY prescription_id";
    pstmt = conn.prepareStatement(query);
    if (search != null && !search.trim().isEmpty()) {
      pstmt.setString(1, "%" + search.toLowerCase() + "%");
    }

    rs = pstmt.executeQuery();
%>

<h2>All Prescriptions</h2>

<div class="search-form">
  <form method="get">
    <input type="text" name="search" placeholder="Search by Patient or Doctor ID" value="<%= (search != null ? search : "") %>"/>
    <button type="submit">Search</button>
  </form>
</div>

<table>
  <tr>
    <th>Prescription ID</th>
    <th>Appointment ID</th>
    <th>Patient ID</th>
    <th>Doctor ID</th>
    <th>Prescription Date</th>
    <th>Medicine ID</th>
    <th>Notes</th>
    <th>Actions</th>
  </tr>

<%
    while (rs.next()) {
      int presId = rs.getInt("prescription_id");
      int appId = rs.getInt("appointment_id");
      int patId = rs.getInt("patient_id");
      int docId = rs.getInt("doctor_id");
      String presDate = rs.getDate("prescription_date").toString();
      int medId = rs.getInt("medicine_id");
      String prescriptionNotes = rs.getString("notes");
%>
  <tr>
    <td><%= presId %></td>
    <td><%= appId %></td>
    <td><%= patId %></td>
    <td><%= docId %></td>
    <td><%= presDate %></td>
    <td><%= medId %></td>
    <td><%= prescriptionNotes %></td>
    <td>
      <a class="update-btn" href="edit_prescription.jsp?update_prescription_id=<%= presId %>&appointment_id=<%= appId %>&patient_id=<%= patId %>&doctor_id=<%= docId %>&prescription_date=<%= presDate %>&medicine_id=<%= medId %>&notes=<%= prescriptionNotes %>">Update</a>
      <form method="post" class="inline">
        <input type="hidden" name="id" value="<%= presId %>"/>
        <input type="hidden" name="action" value="delete"/>
        <button type="submit" class="delete-btn">Delete</button>
      </form>
    </td>
  </tr>
<%
    }

    rs.close();
    pstmt.close();
    conn.close();
  } catch (Exception e) {
%>
  <div class="message error">Error: <%= e.getMessage() %></div>
<%
  }
%>
</table>

<div class="nav-links">
  <a href="prescription.html">Add New Prescription</a>
  <a href="medical_history.jsp">View Medical History</a>
</div>

</body>
</html>
