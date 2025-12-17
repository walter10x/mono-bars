import { IsNotEmpty, IsNumber, IsString, Max, Min, MinLength, MaxLength } from 'class-validator';

export class CreateReviewDto {
  @IsNotEmpty({ message: 'El ID del bar es requerido' })
  @IsString()
  barId: string;

  @IsNotEmpty({ message: 'La valoración es requerida' })
  @IsNumber()
  @Min(1, { message: 'La valoración mínima es 1' })
  @Max(5, { message: 'La valoración máxima es 5' })
  rating: number;

  @IsNotEmpty({ message: 'El comentario es requerido' })
  @IsString()
  @MinLength(10, { message: 'El comentario debe tener al menos 10 caracteres' })
  @MaxLength(500, { message: 'El comentario no puede exceder 500 caracteres' })
  comment: string;
}
