<%@ page import="java.text.DecimalFormat" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="footer.css">
<script>
function delCart(cartUuid) {
    var frm = document.getElementById("frmCartDel");
    frm.processType.value = "P";
    frm.cartUuid.value = cartUuid;
    frm.submit();
}

function delCartAll() {
    var frm = document.getElementById("frmCartDel");
    frm.processType.value = "A";
    frm.cartUuid.value = "";
    frm.submit();
}

function processPayment() {
    if(confirm("결제 하시겠습니까?")) {
        var frm = document.getElementById("frmPay");
        frm.submit();
    }
}
</script>
</head>
<body>
<%
DecimalFormat df = new DecimalFormat("###,###");
String sCategoryCd = request.getParameter("categoryCd");

// 카테고리별 이미지 배열 (상품 개수와 맞춰야 합니다)
String[] bouquetImgs = {"bouquet1.png", "다발2.png", "다발3.png", "다발4.png", "다발5.png"};
String[] basketImgs = {"바구니 1.png", "바구니 2.png", "바구니 3.png", "바구니 4.png", "바구니 5.png"};
String[] singleImgs = {"송이 1.png", "송이 2.png", "송이 3.png", "송이 4.png", "송이 5.png"};
String[] potImgs = {"화분 1.png", "화분 2.png", "화분 3.png", "화분 4.png", "화분 5.png"};

// 카테고리 코드로 폴더/이미지 배열 선택
String folder = "bouquet";
String[] imgList = bouquetImgs;
if ("01".equals(sCategoryCd)) {
    folder = "bouquet"; imgList = bouquetImgs;
} else if ("02".equals(sCategoryCd)) {
    folder = "basket"; imgList = basketImgs;
} else if ("03".equals(sCategoryCd)) {
    folder = "single"; imgList = singleImgs;
} else if ("04".equals(sCategoryCd)) {
    folder = "pot"; imgList = potImgs;
}

long lTotPrice = 0;
ResultSet rs = null;
PreparedStatement pstmt = null;
java.util.List<java.util.Map<String, Object>> cartList = new java.util.ArrayList<>();
try {
    StringBuffer sql = new StringBuffer();
    sql.append("SELECT A.CART_UUID, A.PRODUCT_UUID, A.QUANTITY");
    sql.append(" , B.CATEGORY_CD, B.PRODUCT_NAME, B.PRODUCT_PRICE");
    sql.append(" FROM cart A");
    sql.append(" INNER JOIN product B ON A.PRODUCT_UUID = B.PRODUCT_UUID");
    if (sCategoryCd != null && !sCategoryCd.trim().isEmpty()) {
        sql.append(" WHERE B.CATEGORY_CD = ?");
    }
    sql.append(" ORDER BY A.CART_UUID ASC");
    pstmt = conn.prepareStatement(sql.toString());
    if (sCategoryCd != null && !sCategoryCd.trim().isEmpty()) {
        pstmt.setString(1, sCategoryCd);
    }
    rs = pstmt.executeQuery();
    while (rs.next()) {
        java.util.Map<String, Object> map = new java.util.HashMap<>();
        map.put("cart_uuid", rs.getString("CART_UUID"));  // 삭제 시 사용
        map.put("product_name", rs.getString("PRODUCT_NAME"));
        map.put("product_price", rs.getInt("PRODUCT_PRICE"));
        map.put("quantity", rs.getInt("QUANTITY"));      // 수량 표시
        map.put("category_cd", rs.getString("CATEGORY_CD"));
        cartList.add(map);
        lTotPrice += rs.getInt("PRODUCT_PRICE") * rs.getInt("QUANTITY");
    }
} catch (SQLException ex) {
    out.println("Product 테이블 호출이 실패했습니다.<br>");
    out.println("SQLException: " + ex.getMessage());
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>

<div class="footer">
  <div class="cartPayWrap">
    <div class="cartList">
      <ul>
        <%
        for (int i = 0; i < cartList.size(); i++) {
            java.util.Map<String, Object> prod = cartList.get(i);
            String imgFile = (i < imgList.length) ? imgList[i] : "default.png";
            String sCartUuid = (String) prod.get("cart_uuid");
        %>
        <li>
          <div class="cartProduct">
            <div class="cartProductImg">
              <img src="<%=request.getContextPath() + "/images/" + folder + "/" + imgFile%>" alt="상품이미지">
            </div>
            <div class="cartProductInfo">
              <div class="cartProductName"><%=prod.get("product_name")%></div>
              <div class="cartProductPrice">&#8361; <%=df.format(prod.get("product_price"))%></div>
              <div class="cartProductQuantity">수량: <%=prod.get("quantity")%></div>
            </div>
            <div class="cartProductDel" onclick="delCart('<%= sCartUuid %>');">
              <label style="cursor: pointer;">X</label>
            </div>
          </div>
        </li>
        <% } %>

        <%
        if (cartList.size() == 0) {
        %>
        <li>
          <div class="cartProduct">
            <div class="cartProductImg">
              <img src="./images/coffee_png1.png" alt="빈 장바구니 이미지">
            </div>
          </div>
        </li>
        <% } %>
      </ul>
    </div>

    <div class="payArea">
      <div class="amount">
        <div class="lblPayTxt">
          <label style="width: 100%; color: #FFF200;">총결제금액</label>
        </div>
        <div class="lblPayAmountTxt">
          <label id="amountLbl">&#8361; <%=df.format(lTotPrice)%></label>
        </div>
        <div class="lblPayCancel">
          <label style="width: 100%; color: #FFFA99; cursor: pointer;" onclick="delCartAll();">전체취소</label>
        </div>
      </div>
      <div class="pay" onclick="processPayment();">
        <label>결제</label>
      </div>
    </div>
  </div>
</div>

<form id="frmCartDel" name="frmCartDel" method="post" action="cartDel.jsp">
    <input type="hidden" id="shopDeviceId" name="shopDeviceId" value="<%= sShopDeviceId %>">
    <input type="hidden" id="categoryCd" name="categoryCd" value="<%= sCategoryCd %>">
    <input type="hidden" id="cartUuid" name="cartUuid" value="">
    <input type="hidden" id="processType" name="processType" value="">
</form>

<form id="frmPay" name="frmPay" method="post" action="paySave.jsp"></form>

</body>
</html>
