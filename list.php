<!--List All Customer Invoices Script, Run it from index.php-->
<?php
$customerId = $customerIdErr = $invoices_query = $founded_invoices
    = $query = $foundedId = $invoices = $result = $feedback = '';

if (isset($_POST['submit'])) {
    if (empty($_POST['customerId'])) $customerIdErr = 'Customer ID is required';
    else $customerId = filter_input(INPUT_POST, 'customerId', FILTER_SANITIZE_NUMBER_INT);
    if (empty($customerIdErr)) {
        $sql = "select id from customer where id =$customerId";
        if (!empty($conn)) {
            $query = mysqli_query($conn, $sql);
            if ($query) {
                while ($row = $query->fetch_assoc()) {
                    $foundedId = $row['id'];
                }
            } else echo 'Error: ' . mysqli_error($conn);
        }
    }
}
?>
    <form method="POST" action="<?php echo htmlspecialchars($_SERVER['PHP_SELF']); ?>">
        <div class="list_invoices">
            <input type="number" class="input-0 <?php echo !$customerIdErr ?: 'is-invalid'; ?>"
                   id="customerId" name="customerId" placeholder="Customer ID" value="<?php echo $customerId; ?>">
            <input class="btn-1" type="submit" name="submit" value="List Invoices">
        </div>
    </form>
<?php
if ($foundedId) {
    if (!empty($conn)) {
        // it is good practice to include invoice lines in real world example and design a link to visit full invoice
        // -not implemented here-
        $invoicesSql = "SELECT u.invoice_number as 'Invoice NO', u.total_price as 'Total Price',
                            cl.name as 'Customer Name', s.name as 'Issued Staff', u.issued_date as 'Issued Date'
                            FROM invoice u
                            INNER JOIN staff s ON u.issued_by=s.id
                            INNER JOIN customer cl ON cl.id=u.customer_id
                            WHERE cl.id = $foundedId";
        $invoices_query = mysqli_query($conn, $invoicesSql);
        if ($invoices_query) {
            echo "<h4>Founded Invoices:</h4>";
            echo "<div class='invoice_display'>";
            echo "<ul>";
            echo "<li> Invoice NO </li>";
            echo "<li> Issued Date </li>";
            echo "<li> Issued Staff </li>";
            echo "<li> Customer Name </li>";
            echo "<li> Total Price </li>";
            echo "</ul>";
            echo "</div>";
            while ($invoice = $invoices_query->fetch_assoc()) {
                echo "<div class='invoice_display'>";
                echo "<ul>";
                echo "<li> {$invoice['Invoice NO']} </li>";
                echo "<li> {$invoice['Issued Date']} </li>";
                echo "<li> {$invoice['Issued Staff']} </li>";
                echo "<li> {$invoice['Customer Name']} </li>";
                echo "<li> {$invoice['Total Price']} </li>";
                echo "</ul>";
                echo "</div>";
            }
        }elseif (mysqli_num_rows($invoices_query) == 0) {
            echo "<div>No Invoices found.</div>";
        }
        else echo 'Error: ' . mysqli_error($conn);
    }
}
?>

