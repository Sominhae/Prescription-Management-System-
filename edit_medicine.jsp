<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Edit Medicine</title>
  <style>
    body { font-family: Arial; background: #f4f4f4; padding: 30px; }
    form { max-width: 600px; margin: auto; background: #fff; padding: 20px; border-radius: 10px; }
    label { display: block; margin-top: 10px; font-weight: bold; }
    input, textarea { width: 100%; padding: 8px; margin-top: 5px; }
    button { margin-top: 20px; padding: 10px 15px; background: #2C3E50; color: white; border: none; border-radius: 5px; }
    .message { text-align: center; padding: 10px; margin-bottom: 20px; }
    .success { background: #d4edda; color: #155724; }
    .error { background: #f8d7da; color: #721c24; }
    a { display: block; text-align: center; margin-top: 20px; color: #2C3E50; text-decoration: none; }
  </style>
</head>
<body>

<%
  String medicine_id = request.getParameter("medicine_id");
  String name = request.getParameter("name");
  String category = request.getParameter("category");
  String description = request.getParameter("description");
  String side_effects = request.getParameter("side_effects");
  String manufacture = request.getParameter("manufacture");
  String expire = request.getParameter("expire");
  String updated = request.getParameter("updated");

  if ("true".equals(updated)) {
%>
  <div class="message success">✅ Medicine updated successfully!</div>
<%
  }

  if (request.getMethod().equals("POST")) {
    try {
      String newId = request.getParameter("medicine_id");
      String newName = request.getParameter("name");
      String newCategory = request.getParameter("category");
      String newDescription = request.getParameter("description");
      String newSideEffects = request.getParameter("side_effects");
      String newManufacture = request.getParameter("manufacture");
      String newExpire = request.getParameter("expire");

      Class.forName("oracle.jdbc.driver.OracleDriver");
      Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

      String update = "UPDATE medicine SET name=?, category=?, description=?, side_effects=?, manufacture=TO_DATE(?, 'YYYY-MM-DD'), expire=TO_DATE(?, 'YYYY-MM-DD') WHERE medicine_id=?";
      PreparedStatement ps = con.prepareStatement(update);
      ps.setString(1, newName);
      ps.setString(2, newCategory);
      ps.setString(3, newDescription);
      ps.setString(4, newSideEffects);
      ps.setString(5, newManufacture);
      ps.setString(6, newExpire);
      ps.setInt(7, Integer.parseInt(newId));
      ps.executeUpdate();
      ps.close();
      con.close();

      response.sendRedirect("edit_medicine.jsp?medicine_id=" + newId + "&name=" + newName + "&category=" + newCategory + "&description=" + newDescription + "&side_effects=" + newSideEffects + "&manufacture=" + newManufacture + "&expire=" + newExpire + "&updated=true");
      return;
    } catch (Exception e) {
%>
  <div class="message error">❌ Error: <%= e.getMessage() %></div>
<%
    }
  }
%>

<h2 style="text-align:center;">Edit Medicine</h2>

<form method="post" action="edit_medicine.jsp">
  <label>ID (readonly)</label>
  <input type="text" value="<%= medicine_id %>" readonly />
  <input type="hidden" name="medicine_id" value="<%= medicine_id %>" />

  <label>Name</label>
  <input type="text" name="name" value="<%= name %>" required />

  <label>Category</label>
  <input type="text" name="category" value="<%= category %>" required />

  <label>Description</label>
  <textarea name="description" required><%= description %></textarea>

  <label>Side Effects</label>
  <textarea name="side_effects" required><%= side_effects %></textarea>

  <label>Manufacture Date</label>
  <input type="date" name="manufacture" value="<%= manufacture %>" required />

  <label>Expire Date</label>
  <input type="date" name="expire" value="<%= expire %>" required />

  <button type="submit">Update Medicine</button>
</form>

<a href="medicine.jsp">⬅ Back to Medicine List</a>

</body>
</html>
