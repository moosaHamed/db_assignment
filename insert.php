<!--Insert New Customer Script, Run it from index.php-->
<?php
$name = $email = $nationality = $phone = $assignedDiscount = $street = $city = $postalCode = $state = $publicId = '';
$nameErr = $emailErr = $nationalityErr = $phoneErr = $assignedDiscountErr = $streetErr = $cityErr = '';
$postalCodeErr = $stateErr = $publicIdErr = '';

// Form submit
if (isset($_POST['submit'])) {
    // Validate name
    if (empty($_POST['name'])) $nameErr = 'Name is required';
    else $name = filter_input(INPUT_POST, 'name', FILTER_SANITIZE_FULL_SPECIAL_CHARS);

    // Validate email
    if (empty($_POST['email'])) $emailErr = 'Email is required';
    else $email = filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL);

    // Validate nationality
    if (empty($_POST['nationality'])) $nationalityErr = 'Nationality is required';
    else $nationality = filter_input(INPUT_POST, 'nationality', FILTER_SANITIZE_FULL_SPECIAL_CHARS);

    // Validate phone
    if (empty($_POST['phone'])) $phoneErr = 'Phone is required';
    else $phone = filter_input(INPUT_POST, 'phone', FILTER_SANITIZE_NUMBER_INT);

    // Validate assignedDiscount
    if (empty($_POST['assignedDiscount'])) $assignedDiscountErr = 'Assigned Discount is required';
    else $assignedDiscount = filter_input(INPUT_POST, 'assignedDiscount', FILTER_SANITIZE_NUMBER_INT);

    // Validate street
    if (empty($_POST['street'])) $streetErr = 'Street is required';
    else $street = filter_input(INPUT_POST, 'street', FILTER_SANITIZE_FULL_SPECIAL_CHARS);

    // Validate city
    if (empty($_POST['city'])) $cityErr = 'City is required';
    else $city = filter_input(INPUT_POST, 'city', FILTER_SANITIZE_FULL_SPECIAL_CHARS);

    // Validate postalCode
    if (empty($_POST['postalCode'])) $phoneErr = 'postalCode is required';
    else $postalCode = filter_input(INPUT_POST, 'postalCode', FILTER_SANITIZE_NUMBER_INT);

    // Validate state
    if (empty($_POST['state'])) $stateErr = 'State is required';
    else $state = filter_input(INPUT_POST, 'state', FILTER_SANITIZE_FULL_SPECIAL_CHARS);

    $last_public_id = "select public_id from customer order by  id desc limit 1";
    if (!empty($conn)) {
        $query = mysqli_query($conn, $last_public_id);
        if ($query) {
            while ($row = $query->fetch_assoc()) {
                $publicId = $row['public_id'] + 1;
            }
        } else $publicIdErr = 'Cannot Fetch Last Customer Public-Id' . mysqli_error($conn);
    }

    $addr = new stdClass();
    $addr->street = $street;
    $addr->city = $city;
    $addr->PO = $postalCode;
    $addr->state = $state;
    $address = json_encode($addr);
    if (empty($nameErr) && empty($emailErr) && empty($nationalityErr) && empty($phoneErr) && empty($assignedDiscountErr)
        && empty($streetErr) && empty($cityErr) && empty($postalCodeErr) && empty($stateErr) && empty($publicIdErr)) {
        $sql = "insert into customer (name, public_id, address, nationality, email, contact_number, assigned_discount)
              VALUES ('$name', $publicId, '$address' , '$nationality', '$email', $phone, $assignedDiscount);";
        if (!empty($conn)) {
            if (mysqli_query($conn, $sql)) echo 'Success';
            else echo 'Error: ' . mysqli_error($conn);
        }
    }
}
?>
<form method="POST" action="<?php echo htmlspecialchars($_SERVER['PHP_SELF']); ?>" class="card-grid-1">
    <h4>Register new customer</h4>
    <div class="grid-2">
        <div class="input_label">
            <label for="name">Name.</label>
            <input type="text" id="name" name="name" placeholder="Enter your name" value="<?php echo $name; ?>">
        </div>
        <div class="input_label">
            <label for="email" class="form-label">Email.</label>
            <input type="email" id="email" name="email" placeholder="Enter your email" value="<?php echo $email; ?>">
        </div>
    </div>
    <div class="grid-3">
        <div class="input_label">
            <label for="nationality">Nationality.</label>
            <input type="text" id="nationality" name="nationality" placeholder="Nationality" value="<?php echo $nationality; ?>">
        </div>
        <div class="input_label">
            <label for="phone">Phone.</label>
            <input type="number" id="phone" name="phone" placeholder="Phone" value="<?php echo $phone; ?>">
        </div>
        <div class="input_label">
            <label for="assignedDiscount">Assigned Discount.</label>
            <input type="number" id="assignedDiscount" name="assignedDiscount" placeholder="Assigned Discount"
                   value="<?php echo $assignedDiscount; ?>">
        </div>
    </div>
    <h5>Address</h5>
    <div class="input_label">
        <label for="street">Street.</label>
        <input type="text" id="street" name="street" placeholder="Street" value="<?php echo $street; ?>">
    </div>
    <div class="grid-3">
        <div class="input_label">
            <label for="city">City.</label>
            <input type="text" id="city" name="city" placeholder="City" value="<?php echo $city; ?>">
        </div>
        <div class="input_label">
            <label for="postalCode">P.O.</label>
            <input type="number" id="postalCode" name="postalCode" placeholder="P.O." value="<?php echo $postalCode; ?>">
        </div>
        <div class="input_label">
            <label for="state">State.</label>
            <input type="text" id="state" name="state" placeholder="State" value="<?php echo $state; ?>">
        </div>
    </div>
    <div class="submit-btn">
        <input class="btn-0" type="submit" name="submit" value="submit">
    </div>
</form>
