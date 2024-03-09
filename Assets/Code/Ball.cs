using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ball : MonoBehaviour
{
    [SerializeField] float _ballHorizontalSpeed = 1f, _ballTerminalVelocity = -5f, _ballBounciness = 5f, _ballWeight = 1f;
    Vector3 _groundPosition, _leftWallPosition, _rightWallPosition;
    float _horizontalDirection = 1f, _verticalVelocity = 0f, _verticalDirection = 1f;

    void Start()
    {
        _groundPosition = GetPointInDirection(Vector3.down);
        _rightWallPosition = GetPointInDirection(Vector3.right);
        _leftWallPosition = GetPointInDirection(Vector3.left);
    }

    Vector3 GetPointInDirection(Vector3 direction)
    {
        Physics.Raycast(transform.position, direction, out RaycastHit raycastHit, Mathf.Infinity, ~0);
        return raycastHit.point;
    }

    void Update()
    {
        HorizontalMovement();
        DotProductVerticalMovement();
    }

    void HorizontalMovement()
    {
        transform.position += Vector3.right * _horizontalDirection * _ballHorizontalSpeed * Time.deltaTime;

        Vector3 wallHorizontalPosition = _horizontalDirection < 0f ? _leftWallPosition : _rightWallPosition;
        Vector3 wallHorizontalDirection = Vector3.Normalize(wallHorizontalPosition - transform.position);
        
        if (Vector3.Dot(wallHorizontalDirection, transform.right * _horizontalDirection) < 0f)
            _horizontalDirection *= -1f;
    }

    // Uses dot product and does not use sine. Does bounce in the middle.
    void DotProductVerticalMovement()
    {
        float verticalPosition = _verticalDirection * Mathf.Cos((transform.position.x - _leftWallPosition.x) * (Mathf.PI / Mathf.Abs(_leftWallPosition.x - _rightWallPosition.x)));
        transform.position = new(transform.position.x, verticalPosition, transform.position.z);
        
        Vector3 groundDirection = Vector3.Normalize(_groundPosition - transform.position);
        if (Vector3.Dot(groundDirection, transform.up * -1f) < 0f)
            _verticalDirection *= -1f;
    }

    // Does the bounce with a sine.
    void SineVerticalMovement()
    {
        float progress = Mathf.InverseLerp(_leftWallPosition.x, _rightWallPosition.x, transform.position.x);
        // Jump over the section where the function would give values below 0.
        if (progress > 0.5f) progress += 1f;
        float verticalPosition = Mathf.Sin(progress * Mathf.PI + (Mathf.PI * 0.5f));
        transform.position = new(transform.position.x, verticalPosition, transform.position.z);
    }

    // Uses dot product to check if the ball hit the ground.
    // Does not bounce in the middle because I didn't read the instructions properly before writing it.
    void PseudoPhysicsVerticalMovement()
    {
        if (_verticalVelocity <= _ballTerminalVelocity)
        {
            _verticalVelocity = _ballTerminalVelocity;
        }
        else
        {
            _verticalVelocity -= _ballWeight * Time.deltaTime;
        }

        transform.position += Vector3.up * _verticalVelocity * Time.deltaTime;


        Vector3 groundDirection = Vector3.Normalize(_groundPosition - transform.position);

        if (Vector3.Dot(groundDirection, transform.up * -1f) < 0f)
        {
            _verticalVelocity = _ballBounciness;
        }
    }
}
