<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp"%>
<%
response.setHeader("Cache-Control", "no-cache");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

String sCategoryCd = request.getParameter("categoryCd");
String folder = "bouquet"; // 기본값
String[] imgList = {};

if ("01".equals(sCategoryCd)) {
    folder = "bouquet";
    imgList = new String[]{"bouquet1.png", "다발2.png", "다발3.png", "다발4.png", "다발5.png"};
} else if ("02".equals(sCategoryCd)) {
    folder = "basket";
    imgList = new String[]{"바구니 1.png", "바구니 2.png", "바구니 3.png", "바구니 4.png", "바구니 5.png"};
} else if ("03".equals(sCategoryCd)) {
    folder = "single";
    imgList = new String[]{"송이 1.png", "송이 2.png", "송이 3.png", "송이 4.png", "송이 5.png"};
} else if ("04".equals(sCategoryCd)) {
    folder = "pot";
    imgList = new String[]{"화분 1.png", "화분 2.png", "화분 3.png", "화분 4.png", "화분 5.png"};
}

// DB에서 해당 카테고리 상품 불러오기
PreparedStatement pstmt = null;
ResultSet rs = null;
java.util.List<java.util.Map<String, Object>> productList = new java.util.ArrayList<>();

try {
    String sql = "SELECT product_uuid, product_name, product_price, category_cd FROM product WHERE category_cd = ? ORDER BY product_uuid ASC";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, sCategoryCd);
    rs = pstmt.executeQuery();
    while (rs.next()) {
        java.util.Map<String, Object> map = new java.util.HashMap<>();
        map.put("product_uuid", rs.getString("product_uuid"));
        map.put("product_name", rs.getString("product_name"));
        map.put("product_price", rs.getInt("product_price"));
        map.put("category_cd", rs.getString("category_cd"));
        productList.add(map);
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>
<!DOCTYPE html>
<html>
<head>
    <title>상품 목록</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="./style.css">
    <script>
    function addCart(productUuid) {
        var frm = document.getElementById("frmProduct");
        frm.productUuid.value = productUuid;
        frm.submit();
    }
    </script>
</head>
<body>
    <jsp:include page="header.jsp" flush="true" />
    <section>
        <jsp:include page="menu.jsp" flush="true" />
    </section>
    <section>
        <div>

            <!-- 추가된 폼 시작 -->
            <form id="frmProduct" name="frmProduct" action="cartSave.jsp" method="post">
                <input type="hidden" id="categoryCd" name="categoryCd" value="<%=sCategoryCd%>">
                <input type="hidden" id="productUuid" name="productUuid">
            </form>
            <!-- 추가된 폼 끝 -->

            <ul class="productList">
                <%
                for (int i = 0; i < productList.size(); i++) {
                    java.util.Map<String, Object> prod = productList.get(i);
                    String imgFile = (i < imgList.length) ? imgList[i] : "default.png";
                    String productUuid = (String) prod.get("product_uuid");
                %>
                <li class="productCard">
                    <div class="item-container" onclick="addCart('<%=productUuid%>')">
                        <div class="productImg">
                            <img src="<%=request.getContextPath() + "/images/" + folder + "/" + imgFile%>" alt="제품이미지" style="cursor:pointer;">
                        </div>
                        <div class="productName"><%=prod.get("product_name")%></div>
                        <div class="productPrice">&#8361; <%=String.format("%,d", prod.get("product_price"))%></div>
                    </div>
                </li>
                <%
                }
                if (productList.size() == 0) {
                %>
                <li><label>조회된 상품이 없습니다.</label></li>
                <%
                }
                %>
            </ul>
        </div>
    </section>
    <section>
        <jsp:include page="footer.jsp" flush="true" />
    </section>
</body>
</html>
