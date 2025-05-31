<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>지올스</title>
<link rel="stylesheet" href="./style.css">
</head>
<body>
	<jsp:include page="header.jsp" flush="true" />
	<jsp:include page="menu.jsp" flush="true" />
	<section>
		<jsp:include page="main.jsp" flush="true" />
	</section> 
	<jsp:include page="footer.jsp" flush="true" />
</body>
</html>