<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="header.jsp" %>
<%@ include file="menuMag.jsp" %>
<%@ include file="dbconn.jsp" %>

<%! 
    public static class ProductItem {
        public String productUuid;
        public String categoryCd;
        public String categoryNm;
        public String productName;
        public int productPrice;
        public int productQuantity;
        public String productDesc;
        public String regDt;
        public String uptDt;
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    String sCategoryCd = request.getParameter("sCategoryCd") == null ? "" : request.getParameter("sCategoryCd");
    String sProductName = request.getParameter("sProductName") == null ? "" : request.getParameter("sProductName");

    if (conn == null) {
        out.println("<h3 style='color:red; text-align:center;'>DB 연결에 실패했습니다. 관리자에게 문의하세요.</h3>");
        return;
    }

    StringBuffer sql = new StringBuffer();
    sql.append("SELECT PRODUCT_UUID, CATEGORY_CD, ");
    sql.append("DECODE(CATEGORY_CD, '01', '장미', '02', '백합', '03', '튤립', '04', '해바라기') AS CATEGORY_NM, ");
    sql.append("PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_QUANTITY, PRODUCT_DESC, REG_DT, UPT_DT ");
    sql.append("FROM PRODUCT ");
    sql.append("WHERE 1=1 ");

    if (!sCategoryCd.equals("")) {
        sql.append("AND CATEGORY_CD = ? ");
    }
    if (!sProductName.equals("")) {
        sql.append("AND PRODUCT_NAME LIKE '%' || ? || '%' ");
    }

    sql.append("ORDER BY CATEGORY_CD ASC ");

    PreparedStatement pstmt = null;
    ResultSet rs = null;

    List<ProductItem> productList = new ArrayList<>();

    try {
        pstmt = conn.prepareStatement(sql.toString());

        int idx = 1;
        if (!sCategoryCd.equals("")) pstmt.setString(idx++, sCategoryCd);
        if (!sProductName.equals("")) pstmt.setString(idx++, sProductName);

        rs = pstmt.executeQuery();

        while (rs.next()) {
            ProductItem item = new ProductItem();
            item.productUuid = rs.getString("PRODUCT_UUID");
            item.categoryCd = rs.getString("CATEGORY_CD");
            item.categoryNm = rs.getString("CATEGORY_NM");
            item.productName = rs.getString("PRODUCT_NAME");
            item.productPrice = rs.getInt("PRODUCT_PRICE");
            item.productQuantity = rs.getInt("PRODUCT_QUANTITY");
            item.productDesc = rs.getString("PRODUCT_DESC");
            item.regDt = rs.getString("REG_DT");
            item.uptDt = rs.getString("UPT_DT");

            productList.add(item);
        }
    } catch (Exception e) {
        out.println("<h3 style='color:red; text-align:center;'>DB 조회 중 오류 발생: " + e.getMessage() + "</h3>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>꽃 상품 관리</title>
    <link rel="stylesheet" href="./style.css">
</head>
<body>
    <h2 style="text-align:center;">꽃 상품 관리</h2>

    <form id="frmProductSearch" name="frmProductSearch" action="productMag.jsp" method="post" onsubmit="return false;">
        <div style="width: 90%; margin: 0 auto;">
            <label>카테고리</label>
            <select id="sCategoryCd" name="sCategoryCd">
                <option value="">전체</option>
                <option value="01" <%= "01".equals(sCategoryCd) ? "selected" : "" %>>장미</option>
                <option value="02" <%= "02".equals(sCategoryCd) ? "selected" : "" %>>백합</option>
                <option value="03" <%= "03".equals(sCategoryCd) ? "selected" : "" %>>튤립</option>
                <option value="04" <%= "04".equals(sCategoryCd) ? "selected" : "" %>>해바라기</option>
            </select>

            <label>상품명</label>
            <input type="text" id="sProductName" name="sProductName" value="<%=sProductName%>" placeholder="상품명 검색">

            <input type="submit" onclick="search();" value="검색">

            <button type="button" onclick="location.href='productAddMag.jsp';" 
                style="margin-left: 20px; background:#28a745; color:#fff; border:none; padding:5px 15px; cursor:pointer;">
                상품추가
            </button>
        </div>
    </form>

    <table border="1" style="width:90%; margin:20px auto; text-align:center;">
        <thead>
            <tr>
                <th>상품 UUID</th>
                <th>카테고리</th>
                <th>상품명</th>
                <th>가격</th>
                <th>재고수량</th>
                <th>상품 설명</th>
                <th>등록일</th>
                <th>수정일</th>
                <th>버튼처리</th>
            </tr>
        </thead>
        <tbody>
            <% for (ProductItem item : productList) { %>
            <tr>
                <td><%= item.productUuid %></td>
                <td><%= item.categoryNm %></td>
                <td><%= item.productName %></td>
                <td><%= item.productPrice %></td>
                <td><%= item.productQuantity %></td>
                <td><%= item.productDesc %></td>
                <td><%= item.regDt %></td>
                <td><%= item.uptDt %></td>
                <td>
                    <button style="background: #ff0000; color:#fff; border:2px solid #ff0000; cursor:pointer;"
                        onclick="productEdit('<%= item.productUuid %>');">수정</button>
                    <button style="background: #ff00ff; color:#fff; border:2px solid #ff00ff; cursor:pointer;"
                        onclick="productDel('<%= item.productUuid %>');">삭제</button>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>

    <script>
        function search() {
            document.getElementById("frmProductSearch").submit();
        }
        function productEdit(productUuid) {
            location.href = "./productEditMag.jsp?productUuid=" + productUuid;
        }
        function productDel(productUuid) {
            if(confirm("정말 삭제하시겠습니까?")) {
                location.href = "./productDelMag.jsp?productUuid=" + productUuid;
            }
        }
    </script>
</body>
</html>
