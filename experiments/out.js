// syntax from the test
describe('Parse', () => {
    it('parses single expressions, tracking location information', done$632 => {
        parse('nil')(parsed);
        assert.equal('nil', parsed.type);
        assert.equal(0, parsed.location.begin);
        assert.equal(3, parsed.location.end);
        done$632();
    });
});