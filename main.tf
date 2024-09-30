# Create an S3 bucket
resource "aws_s3_bucket" "s3bucket"{
    bucket = var.bucketname
    tags = {
        Name = "okim-bucket"
        Environment = "Dev"
    }
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
    bucket = aws_s3_bucket.s3bucket.id
    rule{
        object_ownership = "ObjectWriter"
    }

}

resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.s3bucket.id

    block_public_acls   = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl" {
    depends_on = [ 
        aws_s3_bucket_ownership_controls.ownership,
        aws_s3_bucket_public_access_block.public_access
    ]

    bucket = aws_s3_bucket.s3bucket.id
    acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website_config" {
    bucket = aws_s3_bucket.s3bucket.id
    index_document {
      suffix = "index.html"
    }
}

resource "aws_s3_object" "upload-index-html" {
    bucket = aws_s3_bucket.s3bucket.id
    key = "index.html"
    source = "index.html"
    acl = "public-read"
    content_type = "text/html"
}

resource "aws_s3_object" "upload-error-html" {
    bucket = aws_s3_bucket.s3bucket.id
    key = "error.html"
    source = "error.html"
    acl = "public-read"
    content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.s3bucket.id
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "error.html"
    }
    depends_on = [ aws_s3_bucket_acl.acl ]
}
