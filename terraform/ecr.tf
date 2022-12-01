/*
*
*      AWS Elastic Container Registry Configuration
*
*/

resource "aws_ecr_repository" "is531_ecr" {
    name        = "is531-ecr"
    
    image_scanning_configuration {
        scan_on_push    = true
    }
}