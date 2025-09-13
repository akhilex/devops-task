const request = require('supertest');
const app = require('./app');

describe('GET /', () => {
    it('should return a 200 OK and serve the PNG image', async () => {
        const response = await request(app)
            .get('/')
            .expect(200)
            .expect('Content-Type', 'image/png'); // Verify the response is an image

        // Check that the image data is not empty
        expect(response.body.length).toBeGreaterThan(0);
    });
});