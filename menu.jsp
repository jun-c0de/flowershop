<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
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
            <li><a href="javascript:goMenu('01')">꽃 다발</a></li>
            <li><a href="javascript:goMenu('03')">꽃 송이</a></li>
            <li><a href="javascript:goMenu('02')">꽃바구니</a></li>
            <li><a href="javascript:goMenu('04')">꽃 화분</a></li>
        </ul>
    </nav>
</body>
</html>
