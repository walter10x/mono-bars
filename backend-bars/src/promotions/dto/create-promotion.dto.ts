// src/promotions/dto/create-promotion.dto.ts
import { IsString, IsOptional, IsMongoId, IsNumber, IsDateString, IsBoolean, Min, Max } from 'class-validator';

export class CreatePromotionDto {
  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsMongoId()
  barId: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  discountPercentage?: number;

  @IsDateString()
  validFrom: string;

  @IsDateString()
  validUntil: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @IsOptional()
  @IsString()
  photoUrl?: string;

  @IsOptional()
  @IsString()
  termsAndConditions?: string;
}
