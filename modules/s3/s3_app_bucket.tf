resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.app_name}-${var.stage}"

  tags = {
    Name        = "${var.app_name}-${var.stage}"
    Environment = "${var.stage}"
  }
}

resource "aws_s3_bucket_object" "homeworks" {
  bucket = aws_s3_bucket.app_bucket.bucket
  key    = "homeworks/"
  acl    = "private"
}
