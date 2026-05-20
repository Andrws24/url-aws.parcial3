provider "aws" {
  region = var.region
  profile = "nueva-cuenta"
}

resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "website" {

  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

}

resource "aws_s3_object" "html" {

  bucket = aws_s3_bucket.frontend.id

  key = "index.html"

  source = "../src/index.html"

  content_type = "text/html"

}

resource "aws_s3_object" "css" {

  bucket = aws_s3_bucket.frontend.id

  key = "styles.css"

  source = "../src/styles.css"

  content_type = "text/css"

}

resource "aws_s3_object" "js" {

  bucket = aws_s3_bucket.frontend.id

  key = "app.js"

  source = "../src/app.js"

  content_type = "application/javascript"

}

resource "aws_cloudfront_origin_access_control" "oac" {

  name = "frontend-oac"

  origin_access_control_origin_type = "s3"

  signing_behavior = "always"

  signing_protocol = "sigv4"

}

resource "aws_cloudfront_distribution" "cdn" {

  enabled = true

  default_root_object = "index.html"

  origin {

    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name

    origin_id = "frontend"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

  }

  default_cache_behavior {

    allowed_methods = [
      "GET",
      "HEAD"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    target_origin_id = "frontend"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {

      query_string = true

      cookies {
        forward = "none"
      }

    }

  }

  restrictions {

    geo_restriction {

      restriction_type = "none"

    }

  }

  viewer_certificate {

    cloudfront_default_certificate = true

  }

}

resource "aws_s3_bucket_policy" "allow_cloudfront" {

  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "cloudfront.amazonaws.com"

        }

        Action = "s3:GetObject"

        Resource = "${aws_s3_bucket.frontend.arn}/*"

        Condition = {

          StringEquals = {

            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn

          }

        }

      }

    ]

  })

}

output "frontend_url" {

  value = aws_cloudfront_distribution.cdn.domain_name

}