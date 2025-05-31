<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="./style.css">
<meta charset="UTF-8">
<title>메뉴</title>
<script>
function goMenu(categoryCd) {
    var frm = document.getElementById("frmMenu");
    frm.categoryCd.value = categoryCd;
    frm.submit();
}
</script>
</head>
<body>
	<!-- 숨김 폼 -->
	<form id="frmMenu" name="frmMenu" method="post" action="product.jsp">
		<input type="hidden" id="categoryCd" name="categoryCd">
	</form>
	<nav id="menuArea">
		<ul>
			<li><a href="index.jsp">주문페이지</a></li>
			<li><a href="orderMag.jsp">주문관리</a></li>
			<li><a href="productMag.jsp">상품관리</a></li>
			<li><a href="salesStatus.jsp">매출현황</a></li>
		</ul>
	</nav>
</body>
</html>
