
## For Auto scaling group ##

resource "aws_iam_role" "ssm_mgmt" {
  name = "ssm-mgmt"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_mgmt_attachment" {
  role       = aws_iam_role.ssm_mgmt.id
  policy_arn = data.aws_iam_policy.ssm_managed.arn
}

resource "aws_iam_instance_profile" "ssm" {
  name = "instance-profile"
  role = aws_iam_role.ssm_mgmt.name
}
