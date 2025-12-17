import { IsNumber, IsOptional, IsString, Max, Min, MinLength, MaxLength } from 'class-validator';

export class UpdateReviewDto {
  @IsOptional()
  @IsNumber()
  @Min(1, { message: 'La valoración mínima es 1' })
  @Max(5, { message: 'La valoración máxima es 5' })
  rating?: number;

  @IsOptional()
  @IsString()
  @MinLength(10, { message: 'El comentario debe tener al menos 10 caracteres' })
  @MaxLength(500, { message: 'El comentario no puede exceder 500 caracteres' })
  comment?: string;
}
