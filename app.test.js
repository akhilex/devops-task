const request = require('supertest');
const app = require('./app');

describe('GET /', () => {
    it('should return a 200 OK and "Hello World!"', async () => {
        const response = await request(app).get('/');
        expect(response.statusCode).toBe(200);
        expect(response.body.message).toBe('Hello World!');
    });
});