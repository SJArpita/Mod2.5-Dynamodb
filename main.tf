module "web_app" {
 source = "./modules/web_app"

 name_prefix = "arpita" 

 instance_type  = "t2.micro"
 instance_count = 2
 
 vpc_id        = "vpc-053666abf89648be2"
 public_subnet = true
}
resource "aws_s3_bucket" "example" {
  bucket = "my-tf-s3.sctp-sandbox.com"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.example.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["123456789012"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.example.arn,
      "${aws_s3_bucket.example.arn}/*",
    ]
  }
}
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}


resource "aws_route53_record" "s3site" {
  zone_id = "Z00541411T1NGPV97B5C0"
  name = "my-tf-s3.sctp-sandbox.com"
  type = "A"
  
  alias {
    name = "s3-website-us-east-1.amazonaws.com."
    zone_id = "Z3AQBSTGFYJSTF"
    evaluate_target_health = false
  }
}
