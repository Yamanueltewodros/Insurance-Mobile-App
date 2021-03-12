
class Policy {
  // ignore: non_constant_identifier_names
  final String policy_no;
  // ignore: non_constant_identifier_names
  final String policy_holder_id;
  // ignore: non_constant_identifier_names
  final String start_date;
  // ignore: non_constant_identifier_names
  final String end_date;
  final String premium;
  // ignore: non_constant_identifier_names
  final String product_code;
  // ignore: non_constant_identifier_names
  final String plate_no;
  // ignore: non_constant_identifier_names
  final String policy_status;

  Policy(this.policy_no, this.policy_holder_id, this.start_date, this.end_date,
      this.premium, this.product_code, this.plate_no, this.policy_status);
}
