import { defineCollection, z } from "astro:content";

/** Declaración explícita para evitar autogenerados y warnings */
const projects = defineCollection({
  type: "data",
  schema: z.object({
    title: z.string().optional(),
  }),
});

export const collections = { projects };
