import {
  HttpBadRequest,
  HttpMethodNotAllowed,
} from '@belgattitude/http-exception';
import { JsonApiResponseFactory } from '@your-org/core-lib/api/json-api';
import { JsonApiErrorFactory } from '@your-org/core-lib/api/json-api/json-api-error.factory';
import { assertSafeInteger, stringToSafeInteger } from '@your-org/ts-utils';
import type { NextApiRequest, NextApiResponse } from 'next';
import { PostRepositorySsr } from '@/backend/api/rest/post-repository.ssr';
import { prismaClient } from '@/backend/config/container.config';

export default async function handleGetPost(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method === 'GET') {
    const { id } = req.query;
    const postId = stringToSafeInteger(id);
    const postRepo = new PostRepositorySsr(prismaClient);

    try {
      assertSafeInteger(postId, () => new HttpBadRequest('Wrong param id'));

      return res.json(
        JsonApiResponseFactory.fromSuccess(await postRepo.getPost(postId))
      );
    } catch (e) {
      const apiError = JsonApiErrorFactory.fromCatchVariable(e);
      return res
        .status(apiError.status ?? 500)
        .json(JsonApiResponseFactory.fromError(apiError));
    }
  } else {
    return res
      .status(HttpMethodNotAllowed.STATUS)
      .json(
        JsonApiResponseFactory.fromError(
          `The HTTP ${req.method} method is not supported at this route.`,
          HttpMethodNotAllowed.STATUS
        )
      );
  }
}
